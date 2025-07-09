{
  config,
  lib,
  pkgs,
  inputs,
  desktop,
  ...
}:
with lib;
with builtins;
let
  users = config.personalConfig.users;
in
{
  config = mkMerge [
    {
      programs.zsh.enable = true;
      home-manager.users = mapAttrs (
        user: userConfig:
        if (userConfig.zsh.enable && userConfig.userType == "normal") then
          trace "Enabling zsh for user: ${user}" {
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
                XDG_DATA_DIRS=/var/lib/flatpak/exports/share:/home/sobrien/.local/share/flatpak/exports/share:$XDG_DATA_DIRS
                PATH=$HOME/.bin:$PATH:$HOME/.cargo/bin:$HOME/.local/bin
                EDITOR=${if userConfig.nvim then "nvim" else "vim"}
              '';
              oh-my-zsh = {
                enable = true;
                plugins = [
                  "git"
                  "sudo"
                ];
                theme = userConfig.zsh.theme;
              };
              initExtra = ''
                  alias ls="ls -l --color"
                  alias e=$EDITOR
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
            home = {
              packages = with pkgs; [ freshfetch ];
            };
            programs.direnv.enableZshIntegration = true;
          }
        else
          { }
      ) (filterAttrs (user: userConfig: userConfig.userType != "system") users);
    }
    (lib.mkIf (pkgs.system == "aarch64-darwin") {
      home-manager.users = mapAttrs (user: userConfig: {
        home.sessionPath = [ "/opt/homebrew/bin/" ];
      }) users;
    })
  ];
}
