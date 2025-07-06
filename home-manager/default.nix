{
  nix-index-database,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  unstable-packages = with pkgs.unstable; [
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
    jq
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
  ];
  stable-packages = with pkgs;
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
in {
  options.homeConfig = {
    username = mkOption {
      type = types.str;
      default = "sobrien";
      description = "The username to configure via home manager";
    };
    isNixOs = mkOption {
      type = types.bool;
      default = true;
      description = "Whether nixos distro or not. If false only configs will be installed not packages";
    };
  };
  imports = [./fish ./starship.nix ./git.nix ./gnome.nix ./programs.nix];
  config = {
    home = {
      username = config.homeConfig.username;
      homeDirectory = "/home/${config.homeConfig.username}";
      sessionVariables = {
        EDITOR = "nvim";
        SHELL = "/etc/profiles/per-user/${config.homeConfig.username}/bin/fish";
      };
      stateVersion = "24.11";
      packages = stable-packages ++ unstable-packages;
    };
    programs = {
      home-manager.enable = true;
      nix-index.enable = true;
      nix-index.enableFishIntegration = true;
      nix-index-database.comma.enable = true;
      zellij = {
        enable = true;
        settings = {theme = "catppuccin-mocha";};
      };
    };
  };
}
