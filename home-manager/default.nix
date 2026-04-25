{ config, lib, pkgs, constants ? import ../models/constants.nix, ... }:
with lib;
let
  unstable-packages = with pkgs.unstable; [
    rsync
    fastfetch
    bat
    bottom
    coreutils
    curl
    dust
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
    yazi
    zip
  ] ++ lib.optional (!isNixOs) jq;
  
  # Basic packages everyone needs
  essential-packages = with pkgs; [
    gh # for bootstrapping
  ];
  
  # Development packages (language servers, formatters, linters)
  # Note: Editor (nixcats) is handled by nvim.nix based on user's languages
  dev-packages = with pkgs; [
    tree-sitter

    # language servers
    vscode-langservers-extracted # html, css, json, eslint
    yaml-language-server
    nil # nix

    # formatters and linters
    alejandra # nix
    deadnix # nix
    prettier
    shellcheck
    shfmt
    statix # nix
  ];
  
  # Auto-detect if we're on NixOS
  isNixOs = pkgs.stdenv.isLinux && builtins.pathExists /etc/NIXOS;
  
  # When used within NixOS, username is provided by home.username
  # When used standalone, we need to extract from personalConfig
  hasPersonalConfig = config ? personalConfig && config.personalConfig ? users;
  userList = if hasPersonalConfig
    then attrNames config.personalConfig.users
    else [];
  
  # In standalone mode, assert single user
  standaloneUsername = if length userList == 1 
    then head userList
    else if length userList == 0
    then null  # Will use home.username if set
    else throw "Home-manager standalone configuration requires exactly one user in personalConfig.users, found: ${toString (length userList)}";
  
  # Use standalone username if available, otherwise let home-manager handle it
  username = if standaloneUsername != null
    then standaloneUsername
    else null;
  
  # Get the user's configuration if available
  userConfig = if hasPersonalConfig && username != null && config.personalConfig.users ? ${username}
    then config.personalConfig.users.${username}
    else {};
in
{
  imports = [
    ../models
    ./fish
    ./zsh
    ./bash
    ./shell-injector
    ./homebrew-init.nix
    ./nvim.nix
    ./starship.nix
    ./git.nix
    ./gnome.nix
    ./programs.nix
  ];
  
  config = mkMerge [
    # Only set username if we determined it from personalConfig
    (mkIf (username != null) {
      home = {
        username = username;
        homeDirectory = if pkgs.stdenv.isDarwin 
          then "/Users/${username}" 
          else "/home/${username}";
        sessionVariables = {
          SHELL = "${pkgs.bash}/bin/bash";
        };
      };
    })
    # Always set these regardless of username
    {
      home = {
        stateVersion = if config.personalConfig ? system
          then config.personalConfig.system.nixStateVersion
          else constants.nixStateVersion;
        packages = essential-packages
          ++ unstable-packages
          ++ lib.optionals (userConfig.nvim or false) dev-packages;

        # Common tool paths
        sessionPath = [
          "$HOME/.dotnet/tools"
          "$HOME/.npm-global/bin"
        ];
      };
      # Expire old home-manager generations (keep last 3 days)
      systemd.user.services.hm-gc = {
        Unit.Description = "Remove old home-manager generations";
        Service = {
          Type = "oneshot";
          ExecStart = "${config.programs.home-manager.package}/bin/home-manager expire-generations '-3 days'";
        };
      };
      systemd.user.timers.hm-gc = {
        Unit.Description = "Weekly home-manager generation cleanup";
        Timer = {
          OnCalendar = "weekly";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
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
    }
  ];
}
