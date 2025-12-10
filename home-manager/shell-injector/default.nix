{ config, lib, pkgs, ... }:
with lib;
let
  # Get personalConfig - handle both NixOS and home-manager contexts
  personalConfig = config._module.args.personalConfig or config.personalConfig or {};
  users = personalConfig.users or {};
  
  # Auto-detect if we're on NixOS
  isNixOs = pkgs.stdenv.isLinux && builtins.pathExists /etc/NIXOS;
  
  # Determine username - in home-manager context, use config.home.username
  username = config.home.username or (if length (attrNames users) == 1 then head (attrNames users) else null);
  
  # Get user config
  userConfig = if username != null && users ? ${username} then users.${username} else {};
  
  # Check if this user needs shell injection
  shellInjector = userConfig.shellInjector or "disabled";
  userShell = userConfig.shell or "bash";
  needsInjection = !isNixOs && shellInjector != "disabled";
  
  # Shell paths
  shellPaths = {
    bash = "${pkgs.bash}/bin/bash";
    zsh = "${pkgs.zsh}/bin/zsh";
    fish = "${pkgs.fish}/bin/fish";
  };
  
  # Create injection script that launches the user's preferred shell
  mkInjectionScript = ''
    # Source system configuration first
    if [ -f /etc/zshenv ]; then
        source /etc/zshenv
    fi
    if [ -f /etc/zshrc ]; then
        source /etc/zshrc
    fi
    if [ -f /etc/static/zshrc ]; then
        source /etc/static/zshrc
    fi
    
    # Initialize homebrew if on macOS (append to PATH to preserve Nix precedence)
    if [[ "$(uname)" == "Darwin" ]]; then
        if [[ -e /opt/homebrew/bin/brew ]]; then
            OLD_PATH="$PATH"
            eval "$(/opt/homebrew/bin/brew shellenv)"
            export PATH="$OLD_PATH:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin"
        elif [[ -e /usr/local/bin/brew ]]; then
            OLD_PATH="$PATH"
            eval "$(/usr/local/bin/brew shellenv)"
            export PATH="$OLD_PATH:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin"
        fi
    fi
    
    # Shell injector - launches ${userShell}
    NIX_SHELL="${shellPaths.${userShell}}"
    
    # Only exec if not already in target shell and in interactive mode
    if [[ -n "''${PS1-}" && "$SHELL" != "$NIX_SHELL" ]]; then
        # Check parent process to avoid infinite loops
        PARENT_PROCESS=$(ps -p $PPID -o comm= 2>/dev/null || echo "unknown")
        
        # Check if parent is a known terminal application
        case "$PARENT_PROCESS" in
            *wezterm*|*alacritty*|*kitty*|*Terminal*|*iTerm*|*ghostty*)
                IS_TERMINAL_APP=true
                ;;
            *)
                IS_TERMINAL_APP=false
                ;;
        esac
        
        if [[ "$PARENT_PROCESS" != "${userShell}" ]]; then
            # Allow injection from terminal apps or at shell level 1
            if [[ ''${SHLVL} == 1 ]] || [[ "$IS_TERMINAL_APP" == "true" ]]; then
                # Preserve login shell status
                LOGIN_OPTION=""
                if [[ "$0" == "-"* ]] || [[ -o login ]] 2>/dev/null; then
                    LOGIN_OPTION="--login"
                fi
                
                # Set SHELL environment variable and exec
                export SHELL="$NIX_SHELL"
                exec "$NIX_SHELL" $LOGIN_OPTION
            fi
        fi
    fi
  '';
  
in {
  config = mkIf needsInjection {
    home.file = mkMerge [
      # Inject into bash if specified
      (mkIf (shellInjector == "bash") {
        ".bashrc".text = mkInjectionScript;
        ".bash_profile".text = ''
          # Source bashrc for login shells
          if [ -f ~/.bashrc ]; then
              . ~/.bashrc
          fi
        '';
      })
      # Inject into zsh if specified
      (mkIf (shellInjector == "zsh") {
        ".zshrc".text = mkInjectionScript;
        ".zprofile".text = ''
          # Source zshrc for login shells
          if [ -f ~/.zshrc ]; then
              . ~/.zshrc
          fi
        '';
      })
    ];
  };
}