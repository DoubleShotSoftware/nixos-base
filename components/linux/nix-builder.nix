{ config, lib, options, pkgs, ... }:
with lib;
let
  users = config.personalConfig.users;
  nixOSBuilders = (lib.attrsets.mapAttrs' (user: userConfig:
    (trace "Enabling bind for /etc/nixos to /home/${user}/.nixos"
      lib.attrsets.nameValuePair ("/home/${user}/.nixos") ({
        device = "/etc/nixos";
        fsType = "none";
        options = [ "bind" "X-mount.mkdir" ];
      }))) (filterAttrs (user: userConfig: userConfig.nixBuilder) users));
  nixBuilders = mapAttrsToList (user: userConfig: user)
    (filterAttrs (user: userConfig: userConfig.nixBuilder) users);
  adminUsers = mapAttrsToList (user: userConfig: user)
    (filterAttrs (user: userConfig: userConfig.admin) users);
in {
  config = lib.mkMerge ([
    { fileSystems = nixOSBuilders; }
    {
      users.groups = {
        "nix-builders" = { members = nixBuilders; };
        "wheel" = { members = adminUsers; };
      };
    }
  ]);
}
