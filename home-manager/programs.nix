{config, lib, pkgs, ...}: 
let
  # Get personalConfig - handle both NixOS and home-manager contexts
  personalConfig = config._module.args.personalConfig or config.personalConfig or {};
  users = personalConfig.users or {};
  
  # Determine username - in home-manager context, use config.home.username
  username = config.home.username or (if lib.length (lib.attrNames users) == 1 then lib.head (lib.attrNames users) else null);
  
  # Get user config
  userConfig = if username != null && users ? ${username} then users.${username} else {};
  
  # Determine the user's shell
  userShell = userConfig.shell or "bash";
in {
  programs = {
    fzf = {
      enable = true;
      enableBashIntegration = userShell == "bash";
      enableFishIntegration = userShell == "fish";
      enableZshIntegration = userShell == "zsh";
    };
    lsd = {
      enable = true;
      enableBashIntegration = userShell == "bash";
      enableFishIntegration = userShell == "fish";
      enableZshIntegration = userShell == "zsh";
    };
    zoxide = {
      enable = true;
      enableBashIntegration = userShell == "bash";
      enableFishIntegration = userShell == "fish";
      enableZshIntegration = userShell == "zsh";
      options = ["--cmd cd"];
    };
    broot = {
      enable = true;
      enableBashIntegration = userShell == "bash";
      enableFishIntegration = userShell == "fish";
      enableZshIntegration = userShell == "zsh";
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
