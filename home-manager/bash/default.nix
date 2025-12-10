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
  
  # Check if bash should be enabled for this user
  enableBash = (userConfig.shell or null) == "bash";
  
in {
  config = mkIf enableBash {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoredups" "ignorespace" ];
      
      shellAliases = {
        cat = "bat";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
      };
      
      initExtra = ''
        # Set prompt
        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
        
        # Display system info
        if [[ "$(uname -a |awk '{print $1}')" == "Darwin" ]]
        then 
          ${pkgs.freshfetch}/bin/freshfetch --ascii_distro mac
        else 
          ${pkgs.freshfetch}/bin/freshfetch --ascii_distro nixos 
        fi
      '';
    };
    
    home.packages = with pkgs; [ freshfetch ];
    
    programs.direnv.enableBashIntegration = true;
    
    # Enable homebrew initialization on macOS
    programs.homebrew-init.enable = pkgs.stdenv.isDarwin;
  };
}
