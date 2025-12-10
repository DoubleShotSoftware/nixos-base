{ config, lib, pkgs, ... }:
with lib;
let
  users = config.personalConfig.users;
in {
  config = {
    users.users = mapAttrs (user: userConfig:
      trace "Creating user: ${user}" {
        name = user;
        home = "/home/${user}";
        shell = 
          if (userConfig.shell == "zsh") then pkgs.zsh 
          else if (userConfig.shell == "fish") then pkgs.fish
          else pkgs.bash;
        group = user;
        isNormalUser = userConfig.userType == "normal";
        isSystemUser = userConfig.userType == "system";
        extraGroups = userConfig.extraGroups;
        openssh.authorizedKeys.keyFiles = userConfig.keys.ssh;
      }) users;
    
    users.groups = mapAttrs (user: userConfig:
      trace "Creating group for user: ${user} named: ${user}" {
        name = user;
        members = [ user ];
      }) users;
  };
}