{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  cfg = config.personalConfig.linux.linger;
  lingeringUsers = cfg.users;
in
{
  options.personalConfig.linux.linger = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable lingering user support.";
    };
    users = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of users with linger support.";
    };
  };

  config = mkIf cfg.enable
    {
      system.activationScripts.update-lingering =
        let
          lingerDir = "/var/lib/systemd/linger";
          lingeringUsersFile = builtins.toFile "lingering-users"
            (concatStrings (map (s: "${s}\n")
              (sort (a: b: a < b) lingeringUsers)));  # this sorting is important for `comm` to work correctly
        in
        stringAfter [ "users" ] ''
          if [ -e ${lingerDir} ] ; then
            cd ${lingerDir}
            ls ${lingerDir} | sort | comm -3 -1 ${lingeringUsersFile} - | xargs -r ${pkgs.systemd}/bin/loginctl disable-linger
            ls ${lingerDir} | sort | comm -3 -2 ${lingeringUsersFile} - | xargs -r ${pkgs.systemd}/bin/loginctl  enable-linger
          fi
        '';
    };
}
