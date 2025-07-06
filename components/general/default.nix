{ config, lib, options, pkgs, ... }:
with lib;
let
  nixStateVersion = config.personalConfig.system.nixStateVersion;
  users = config.personalConfig.users;
  zshEnabled = config.personalConfig.users.zsh.enable;
  adminUsers = mapAttrsToList (user: userConfig: user)
    (filterAttrs (user: userConfig: userConfig.admin) users);
in {
  imports = [ ../../models ./base.nix ./zsh ./kitty ./wezterm  ./nvim ./vscode.nix ./zellij.nix ./git.nix ];
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
          programs.home-manager = { enable = true; };
          programs.direnv.enable = true;
          programs.direnv.nix-direnv.enable = true;
        })
        (filterAttrs (user: userConfig: userConfig.userType != "system") users);
    }
  ]);
}
