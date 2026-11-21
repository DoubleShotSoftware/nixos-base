{ config, lib, options, pkgs, ... }:
with lib;
let
  nixStateVersion = config.personalConfig.system.nixStateVersion;
  users = config.personalConfig.users;
  zshEnabled = config.personalConfig.users.zsh.enable;
  adminUsers = mapAttrsToList (user: userConfig: user)
    (filterAttrs (user: userConfig: userConfig.admin) users);
in {
  imports = [ ../../models ./base.nix ./kitty ./wezterm ./ghostty ./nvim ./vscode.nix ./vscode-vim ./zellij.nix ./git.nix ];
  config = lib.mkMerge ([
    # Enable shells at the system level if any user uses them
    {
      programs.zsh.enable = mkDefault (any (u: (u.shell or null) == "zsh") (attrValues users));
      programs.fish.enable = mkDefault (any (u: (u.shell or null) == "fish") (attrValues users));
    }
    (lib.mkIf (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") {
      users.users = mapAttrs (user: userConfig: {
          home = "/Users/${user}";
        }) users;
    })
    {
      home-manager.users = mapAttrs (user: userConfig:
        trace "Enabling Home Manager For: ${user}" {
          programs.home-manager = { enable = true; };
        })
        (filterAttrs (user: userConfig: userConfig.userType != "system") users);
    }
  ]);
}
