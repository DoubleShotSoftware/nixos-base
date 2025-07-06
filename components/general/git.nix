{ config, lib, options, pkgs, ... }:
with lib;
let
  users = config.personalConfig.users;
  defaultGitIgnore = builtins.readFile ./git-default.ignore;
  
  gitUserConfigs = mapAttrs (user: userConfig:
    if userConfig.git.enable then
      (trace "Enabling git configuration for user: ${user}" {
        programs.git = {
          enable = true;
          extraConfig = {
            core = {
              excludesFile = "${config.users.users.${user}.home}/.config/git/nixGeneratedExclude.conf";
            };
          };
        };
        
        home.packages = with pkgs; 
          (if userConfig.git.lazy then [ lazygit ] else []) ++
          (if userConfig.git.jujutsu then [ jujutsu ] else []);
        
        home.file.".config/git/nixGeneratedExclude.conf".text = 
          defaultGitIgnore +
          (if userConfig.git.exclude != "" then "\n# User exclude patterns\n" + userConfig.git.exclude else "") +
          (if userConfig.git.extraIgnore != "" then "\n# Extra ignore patterns\n" + userConfig.git.extraIgnore else "");
        
        home.file.".config/git/local-ignore.conf".text = "";
      })
    else
      { }
  ) (filterAttrs (user: userConfig: userConfig.userType != "system") users);
in {
  options.personalConfig.users = mkOption {
    type = types.attrsOf (types.submodule {
      options.git = {
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
    });
  };
  
  config = {
    home-manager.users = gitUserConfigs;
  };
}
