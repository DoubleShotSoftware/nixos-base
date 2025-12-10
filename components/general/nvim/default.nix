{ config, lib, pkgs, ... }:
with lib;
let
  users = config.personalConfig.users;
in {
  config = {
    home-manager.users = mapAttrs (user: userConfig:
      mkIf (userConfig.nvim && userConfig.userType == "normal") {
        home.packages = [ pkgs.nvim-ide ];
        
        # Set up vim/vi aliases to use nvim-ide
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