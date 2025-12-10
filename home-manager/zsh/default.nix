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
  
  # Check if zsh should be enabled for this user
  enableZsh = (userConfig.shell or null) == "zsh";
  
in
{
  config = mkIf enableZsh {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
      };
      dirHashes = {
        downloads = "$HOME/Downloads";
        dev = "$HOME/dev";
      };
      envExtra = ''
        TERM=xterm-256color
        PATH=$HOME/.bin:$HOME/.local/bin:$PATH
        XDG_DATA_DIRS=/var/lib/flatpak/exports/share:/home/${username}/.local/share/flatpak/exports/share:$XDG_DATA_DIRS
        PATH=$HOME/.bin:$PATH:$HOME/.cargo/bin:$HOME/.local/bin
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "sudo"
        ];
        theme = userConfig.zsh.theme or "agnoster";
      };
      initExtra = ''
        alias cat="bat"
        alias ls="ls -l --color"
        if [[ "$(uname -a |awk '{print $1}')" == "Darwin" ]]
        then 
          ${pkgs.freshfetch}/bin/freshfetch --ascii_distro mac
        else 
          ${pkgs.freshfetch}/bin/freshfetch --ascii_distro nixos 
        fi
        if [ -f ./.zsh_local.sh ];
        then
          source ./.zsh_local.sh
        fi
      '';
    };
    
    home.packages = with pkgs; [ freshfetch ];
    
    programs.direnv.enableZshIntegration = true;
    
    # Enable homebrew initialization on macOS
    programs.homebrew-init.enable = pkgs.stdenv.isDarwin;
  };
}