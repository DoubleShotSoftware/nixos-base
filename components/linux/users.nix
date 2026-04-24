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
        # Keep the real login shell POSIX-friendly so remote tooling sees bash.
        # Interactive fish/zsh sessions are restored by the shell injector.
        shell = pkgs.bash;
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
