{
  nix-index-database,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  unstable-packages =
    with pkgs.unstable;
    [
      rsync
      fastfetch
      bat
      bottom
      coreutils
      curl
      du-dust
      fd
      findutils
      fx
      git
      git-crypt
      htop
      killall
      mosh
      procs
      ripgrep
      sd
      tmux
      tree
      unzip
      wget
      zip
    ]
    ++ lib.optional (!config.homeConfig.isNixOs) jq;
  stable-packages =
    with pkgs;
    [
      gh # for bootstrapping
      tree-sitter
      # language servers
      nodePackages.vscode-langservers-extracted # html, css, json, eslint
      nodePackages.yaml-language-server
      nil # nix
      # formatters and linters
      alejandra # nix
      deadnix # nix
      nodePackages.prettier
      shellcheck
      shfmt
      statix # nix
    ]
    ++ lib.optional (pkgs ? nvim-ide) pkgs.nvim-ide;
in
{
  options.homeConfig = {
    username = mkOption {
      type = types.str;
      default = "sobrien";
      description = "The username to configure via home manager";
    };
    systemVersion = mkOption {
      type = types.str;
      default = (import ../constants.nix).defaultStateVersion;
      description = "The version of the home-manager system to use";
    };
    isNixOs = mkOption {
      type = types.bool;
      default = true;
      description = "Whether nixos distro or not. If false only configs will be installed not packages";
    };
  };
  imports = [
    ./fish
    ./starship.nix
    ./git.nix
    ./gnome.nix
    ./programs.nix
  ];
  config = {
    home = {
      username = config.homeConfig.username;
      homeDirectory = "/home/${config.homeConfig.username}";
      sessionVariables = {
        EDITOR = "nvim";
        SHELL = "/etc/profiles/per-user/${config.homeConfig.username}/bin/fish";
      };
      stateVersion = config.homeConfig.systemVersion;
      packages = stable-packages ++ unstable-packages;
    };
    programs = {
      home-manager.enable = true;
      nix-index = {
        enable = true;
        enableFishIntegration = true;
      };
      nix-index-database.comma.enable = true;
      zellij = {
        enable = true;
        settings = {
          theme = "catppuccin-mocha";
        };
      };
    };
  };
}
