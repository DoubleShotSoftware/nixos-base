{ lib }:
with lib;
{
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
    shell = mkOption {
      type = types.enum [ "zsh" "fish" "bash" ];
      description = "The user's preferred shell.";
      default = "bash";
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
    git = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable git configuration for user.";
      };
      exclude = mkOption {
        type = types.str;
        default = "";
        description = "Git ignore patterns to exclude globally for this user.";
      };
      lazy = mkOption {
        type = types.bool;
        default = false;
        description = "Enable lazygit for user.";
      };
      jujutsu = mkOption {
        type = types.bool;
        default = false;
        description = "Enable jujutsu (jj) version control for user.";
      };
      extraIgnore = mkOption {
        type = types.str;
        default = "";
        description = "Additional git ignore patterns to append to the generated ignore file.";
      };
    };
  };
}