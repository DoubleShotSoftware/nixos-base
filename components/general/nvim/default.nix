{ config, lib, pkgs, ... }:
with lib;
let
  users = config.personalConfig.users;
in {
  config = {
    home-manager.users = mapAttrs (user: userConfig:
      let
        userLanguages = userConfig.languages or [];
        nixcatsPackage = if pkgs ? mkNixCatsIDE
          then pkgs.mkNixCatsIDE { languages = userLanguages; }
          else null;
      in
      mkIf (userConfig.nvim && userConfig.userType == "normal" && nixcatsPackage != null) {
        home.packages = [ nixcatsPackage ];

        # Set up vim/vi aliases to use nvim
        programs.bash.shellAliases = {
          vim = "nvim";
          vi = "nvim";
        };

        programs.zsh.shellAliases = mkIf userConfig.zsh.enable {
          vim = "nvim";
          vi = "nvim";
        };
      }
    ) users;
  };
}