{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  # Get personalConfig - handle both NixOS and home-manager contexts
  personalConfig = config._module.args.personalConfig or config.personalConfig or {};
  users = personalConfig.users or {};
  
  # Determine username - in home-manager context, use config.home.username
  username = config.home.username or (if length (attrNames users) == 1 then head (attrNames users) else null);
  
  # Get user config
  userConfig = if username != null && users ? ${username} then users.${username} else {};
  
  # Check if nvim should be enabled for this user
  enableNvim = userConfig.nvim or false;
  
in
{
  config = mkIf enableNvim {
    home.packages = [pkgs.nvim-ide];
    
    # Set EDITOR environment variable globally
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    
    # Add shell aliases for all shells
    # Note: Individual shell modules should not override these
    programs.bash.shellAliases = mkIf (config.programs.bash.enable or false) {
      e = "nvim";
    };
    
    programs.zsh.shellAliases = mkIf (config.programs.zsh.enable or false) {
      e = "nvim";
    };
    
    programs.fish.shellAliases = mkIf (config.programs.fish.enable or false) {
      e = "nvim";
    };
  };
}
