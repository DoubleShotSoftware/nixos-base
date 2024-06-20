{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  csharp-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "csharp-nvim";
    version = "02-19-2024";
    src = pkgs.fetchFromGitHub {
      owner = "iabdelkareem";
      repo = "csharp.nvim";
      rev = "48d72dfad26177295744d6da958f1dc08046a9d9";
      sha256 = "sha256-bULc9btnVwdXKX3NEsMez699DifvKDeVLdQ9tCpbZsg=";
    };
    meta.homepage = "https://github.com/iabdelkareem/csharp.nvim";
  };
  structlog-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "structlog-nvim";
    version = "0.2";
    src = pkgs.fetchFromGitHub {
      owner = "Tastyep";
      repo = "structlog.nvim";
      rev = "v0.2";
      sha256 = "sha256-Bq4YNpLQ1+iSBuN5MG4OBmI5r3DGWyDou4kRCMnked0=";
    };
    meta.homepage = "https://github.com/iabdelkareem/csharp.nvim";
  };
  users = config.personalConfig.users;
  dotnetSDK =
    (with pkgs.dotnetCorePackages; combinePackages [ sdk_6_0 sdk_7_0 sdk_8_0 ]);
  dotNetPackages = with pkgs; [
    roslyn
    dotnetPackages.Nuget
    dotnetPackages.NUnit
    msbuild
    dotnetSDK
    ilspycmd
  ];
  dotnetEnvVars = {
    DOTNET_ROOT = "${dotnetSDK}";
    DOTNET_CLI_TELEMETRY_OPTOUT = 1;
    PATH = "${dotnetSDK}/bin:$HOME/.dotnet/tools:$HOME/.bin:$PATH";
    DOTNET_NOLOGO = "true";
    DOTNET_ADD_GLOBAL_TOOLS_TO_PATH = "true";
    DOTNET_HOST_PATH = "${dotnetSDK}/bin/dotnet";
  };
  dotnetDevelopers = mapAttrs (user: config:
    trace "Enabling dotnet development for user: ${user}" {
      home = {
        packages = dotNetPackages;
        sessionVariables = dotnetEnvVars;
      };
      systemd.user = { sessionVariables = dotnetEnvVars; };
      programs = { zsh = { oh-my-zsh = { plugins = [ "dotnet" ]; }; }; };
    }) (filterAttrs (user: userConfig:
      (any (language: language == "dotnet") userConfig.languages)) users);
  dotnetNVIMDevelopers = mapAttrs (user: config:
    trace "Enabling dotnet nvim development support for user: ${user}" (let
      inherit dotNetPackages;
      lspPackages = with pkgs.unstable; [ uncrustify netcoredbg fd ];
    in {
      home = {
        packages = lspPackages;
        file = {
          ".omnisharp/omnisharp.json" = { source = ./omnisharp.json; };
          ".bin/omnisharp" = {
            executable = true;
            text = ''
              #!${pkgs.bash}/bin/bash
              ${pkgs.omnisharp-roslyn}/bin/OmniSharp "$@"
            '';
          };
        };
      };
      xdg.configFile = {
        "nvim/lua/user/lsp/settings/dotnetpaths.lua".text = ''
          local M = {
              OmniSharp = "${pkgs.omnisharp-roslyn}/bin/OmniSharp",
              CSharpLS = "${pkgs.unstable.csharp-ls}/bin/csharp-ls",
              Root = "${dotnetSDK}"
          }
          return M
        '';
        "nvim/lua/user/lsp/settings/dotnet.lua".source = ./dotnet.lua;
        "nvim/lua/lsp/user/treesitter/dotnet.lua".source = ./treesitter.lua;
      };
      programs = {
        neovim = {
          plugins = with pkgs.unstable.vimPlugins; [
            { plugin = omnisharp-extended-lsp-nvim; }
            { plugin = csharpls-extended-lsp-nvim; }
            { plugin = csharp-nvim; }
            { plugin = structlog-nvim; }
          ];
          extraPackages = lspPackages ++ dotNetPackages;
        };
      };
    })) (filterAttrs (user: userConfig:
      ((any (language: language == "dotnet") userConfig.languages)
        && userConfig.nvim)) users);
in {
  config = lib.mkMerge [
    { home-manager.users = dotnetDevelopers; }
    { home-manager.users = dotnetNVIMDevelopers; }
  ];
}
