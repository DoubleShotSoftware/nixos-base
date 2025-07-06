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
  config = {
    home-manager.users = gitUserConfigs;
  };
}
