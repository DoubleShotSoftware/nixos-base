{ config, lib, options, pkgs, ... }:
with lib;
let
  users = config.personalConfig.users;
  defaultGitIgnore = builtins.readFile ./git-default.ignore;
  
  gitUserConfigs = mapAttrs (user: userConfig:
    if userConfig.git.enable then
      let
        # Generate directory-specific config files
        dirConfigFiles = mapAttrs' (name: dirCfg:
          nameValuePair ".config/git/dir-${name}.conf" {
            text = ''
              [user]
              ${optionalString (dirCfg.userName != null) "  name = ${dirCfg.userName}"}
              ${optionalString (dirCfg.userEmail != null) "  email = ${dirCfg.userEmail}"}
              ${optionalString (dirCfg.signingKey != null) "  signingkey = ${dirCfg.signingKey}"}
            '';
          }
        ) userConfig.git.dirConfig;
      in
      (trace "Enabling git configuration for user: ${user}" {
        programs.git = {
          enable = true;
          
          # Set default user name and email if provided
          userName = mkIf (userConfig.git.userName != null) userConfig.git.userName;
          userEmail = mkIf (userConfig.git.userEmail != null) userConfig.git.userEmail;
          
          extraConfig = {
            core = {
              excludesFile = "${config.users.users.${user}.home}/.config/git/nixGeneratedExclude.conf";
            };
          } // (
            # Generate includeIf blocks for directory-specific configs
            foldl' (acc: name: 
              let dirCfg = userConfig.git.dirConfig.${name};
              in acc // {
                "includeIf \"gitdir:${dirCfg.path}\"" = {
                  path = "${config.users.users.${user}.home}/.config/git/dir-${name}.conf";
                };
              }
            ) {} (attrNames userConfig.git.dirConfig)
          );
        };
        
        home.packages = with pkgs; 
          (if userConfig.git.lazy then [ lazygit ] else []) ++
          (if userConfig.git.jujutsu then [ jujutsu ] else []);
        
        home.file = {
          ".config/git/nixGeneratedExclude.conf".text = 
            defaultGitIgnore +
            (if userConfig.git.exclude != "" then "\n# User exclude patterns\n" + userConfig.git.exclude else "") +
            (if userConfig.git.extraIgnore != "" then "\n# Extra ignore patterns\n" + userConfig.git.extraIgnore else "");
          
          ".config/git/local-ignore.conf".text = "";
        } // dirConfigFiles;
      })
    else
      { }
  ) (filterAttrs (user: userConfig: userConfig.userType != "system") users);
in {
  config = {
    home-manager.users = gitUserConfigs;
  };
}