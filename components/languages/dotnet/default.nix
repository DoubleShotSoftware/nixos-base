{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  users = config.personalConfig.users;
  dotnetSDK =
    (with pkgs.dotnet.dotnetCorePackages; combinePackages [
      sdk_6_0
      sdk_7_0
      sdk_8_0
    ]);
  dotNetPackages = with pkgs.dotnet; [
    roslyn
    dotnetPackages.Nuget
    dotnetPackages.NUnit
    msbuild
    dotnetSDK
  ];
  dotnetEnvVars = {
    DOTNET_ROOT="${dotnetSDK}";
    DOTNET_CLI_TELEMETRY_OPTOUT=1;
    PATH="${dotnetSDK}/bin:$HOME/.dotnet/tools:$HOME/.bin:$PATH";
  };
  dotnetDevelopers = mapAttrs
    (user: config:
      trace ''Enabling dotnet development for user: ${user}''
        {
          home = {
            packages = dotNetPackages;
            sessionVariables = dotnetEnvVars;
          };
          systemd.user = {
            sessionVariables = dotnetEnvVars;
          };
          programs = {
            zsh = {
              oh-my-zsh = { plugins = [ "dotnet" ]; };
            };
          };
        })
    (filterAttrs
      (user: userConfig:
        (any (language: language == "dotnet") userConfig.languages)
      )
      users
    );
  dotnetNVIMDevelopers = mapAttrs
    (user: config:
      trace ''Enabling dotnet nvim development support for user: ${user}'' (
        let
          inherit dotNetPackages;
          lspPackages = with pkgs.unstable; [
            #omnisharp-roslyn
            uncrustify
            astyle
            netcoredbg
          ];
        in
        {
          home = {
            packages = lspPackages;
            file = {
              ".omnisharp/omnisharp.json" = {
                source = ./omnisharp.json;
              };
              #              ".bin/omnisharp.sh" = {
              #                executable = true;
              #                text = ''
              #                  #!${pkgs.bash}/bin/bash
              #                  export DOTNET_ROOT=${dotnetSDK}
              #                  DOTNET_ROOT=${dotnetSDK} ${dotnetSDK}/bin/dotnet "${pkgs.omnisharp-roslyn}/lib/omnisharp-roslyn/OmniSharp.dll" "$@"
              #                '';
              #              };
            };
          };
          xdg.configFile = {
            #"nvim/lua/lsp/settings/dotnet.lua".source = ./dotnet.lua;
            #"nvim/lua/lsp/treesitter/dotnet.lua".source = ./treesitter.lua;
          };
          programs = {
            neovim = {
              #              plugins = with pkgs.unstable.vimPlugins; [
              #                {
              #                  plugin = omnisharp-extended-lsp-nvim;
              #                  config = builtins.readFile (./dotnet.lua);
              #                  type = "lua";
              #                }
              #              ];
              extraPackages = dotNetPackages; #lspPackages ++ dotNetPackages;
            };
          };
        }
      ))
    (filterAttrs
      (user: userConfig:
        (
          (any (language: language == "dotnet") userConfig.languages) &&
          userConfig.nvim
        )
      )
      users
    );
in
{
  config = lib.mkMerge [
    { home-manager.users = dotnetDevelopers; }
    { home-manager.users = dotnetNVIMDevelopers; }
  ];
}
