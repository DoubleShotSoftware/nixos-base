{ config, lib, options, pkgs, ... }:
with lib;
let
  sysOptions = { ... }: {
    options = {
 nixStateVersion      = mkOption {
        type = types.str;
        default = "24.11";
        description = lib.mdDoc "The user's auxiliary groups.";
      };
};
};
  userOptions = { ... }: {
    options = {
      keys = {
        ssh = mkOption {
          type = types.listOf types.path;
          default = [ ];
          description = "A list of paths to ssh keys allowed for this user.";
        };
      };
      desktop = mkOption {
        type = types.enum [ "disabled" "sway" "gnome" "i3" ];
        default = "disabled";
        description = "Enable desktop environment for user.";
      };
      nixBuilder = mkOption {
        type = types.bool;
        description = "Create bind to /etc/nixos under $HOME/.nixos";
        default = false;
      };
      zsh = {
        enable = mkOption {
          type = types.bool;
          description = "Whether to enable zsh for user.";
          default = false;
        };
        theme = mkOption {
          type = types.enum [ "agnoster" ];
          description = "The user's zsh theme.";
          default = "agnoster";
        };
      };
      wezterm = mkOption {
        type = types.bool;
        description = "Whether to enable wezterm for user.";
        default = false;
      };
      kitty = mkOption {
        type = types.bool;
        description = "Whether to enable kitty for user.";
        default = false;
      };
      nvim = mkOption {
        type = types.bool;
        description = "Whether to enable nvim for user.";
        default = false;
      };
      vscode = mkOption {
        type = types.bool;
        description = "Whether to enable vscode for user.";
        default = false;
      };
      userType = mkOption {
        type = types.enum [ "normal" "system" ];
        description = "Whether the user is a system or normal user.";
        default = "system";
      };
      extraGroups = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = lib.mdDoc "The user's auxiliary groups.";
      };
      admin = mkOption {
        type = types.bool;
        default = false;
        description = "Give user sudo access.";
      };
      zellij = mkOption {
        type = types.bool;
        default = false;
        description = "install zellij for user.";
      };
      languages = mkOption {
        type = types.listOf (types.enum [
          "rust"
          "dotnet"
          "python"
          "postgres"
          "typescript"
          "json"
        ]);
        default = [ ];
        description = "Which languages to configure for a user.";
      };
    };
  };
  nixStateVersion = config.personalConfig.system.nixStateVersion;
  users = config.personalConfig.users;
  zshEnabled = config.personalConfig.users.zsh.enable;
  adminUsers = mapAttrsToList (user: userConfig: user)
    (filterAttrs (user: userConfig: userConfig.admin) users);
in {
  options.personalConfig = {
    system = mkOption {
      default = { };
      type = types.attrsOf (types.submodule sysOptions);
      description = "Configure system";
    };
    users = mkOption {
      default = { };
      type = types.attrsOf (types.submodule userOptions);
      description = "Configure a user.";
    };
    machineType = mkOption {
      type = types.enum [ "work" "personal" ];
      default = "personal";
      description =
        "Whether this instance is personal or work based, personal includes more personal related packages.";
    };
	
  };
  imports = [ ./zsh ./kitty ./wezterm ./vscode.nix ./zellij.nix ./git.nix ];
  config = lib.mkMerge ([
    (lib.mkIf (pkgs.system == "aarch64-darwin") {
      users.users = mapAttrs (user: userConfig: {
          home = "/Users/${user}";
        }) users;
    })
    (lib.mkIf (pkgs.system != "aarch64-darwin") {
      users.users = mapAttrs (user: userConfig:
        trace "Creating user: ${user}" {
          name = user;
          home = if (pkgs.system == "aarch64-darwin") then
            "/Users/${user}"
          else
            "/home/${user}";
          shell = if (userConfig.zsh.enable) then pkgs.zsh else pkgs.bash;
          group = user;
          isNormalUser = userConfig.userType == "normal";
          isSystemUser = userConfig.userType == "system";
          extraGroups = userConfig.extraGroups;
          openssh.authorizedKeys.keyFiles = userConfig.keys.ssh;
        }) users;
    })
    (lib.mkIf (pkgs.system != "aarch64-darwin") {
      users.groups = mapAttrs (user: userConfig:
        trace "Creating group for user: ${user} named: ${user}" {
          name = user;
          members = [ user ];
        }) users;
    })
    {
      home-manager.users = mapAttrs (user: userConfig:
        trace "Enabling Home Manager For: ${user}" {
          home = {
            stateVersion = nixStateVersion;
            username = user;
          };
          programs.home-manager = { enable = true; };
          programs.direnv.enable = true;
          programs.direnv.nix-direnv.enable = true;
        })
        (filterAttrs (user: userConfig: userConfig.userType != "system") users);
    }
  ]);
}
