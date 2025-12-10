# Homebrew initialization module for macOS
#
# This module ensures Homebrew is available but with lower PATH precedence than Nix.
# Homebrew paths are explicitly appended to the END of PATH so that:
# 1. Nix packages are preferred when available
# 2. Homebrew provides fallback for macOS-specific tools
# 3. System utilities remain accessible
#
# Expected PATH order:
#   1. Nix user profiles (/etc/profiles/per-user/*/bin)
#   2. Nix system profiles (/run/current-system/sw/bin)
#   3. Nix default profile (/nix/var/nix/profiles/default/bin)
#   4. System paths (/usr/local/bin, /usr/bin, /bin, etc.)
#   5. Homebrew (/opt/homebrew/bin, /opt/homebrew/sbin) ← LAST
#
# To disable Homebrew in PATH, set: programs.homebrew-init.enable = false;
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.programs.homebrew-init = {
    enable = mkEnableOption "homebrew shell initialization";
  };

  config = mkIf (pkgs.stdenv.isDarwin && config.programs.homebrew-init.enable) {
    # Common homebrew initialization for all shells
    programs.zsh.initExtra = mkIf config.programs.zsh.enable (mkAfter ''
      # Initialize homebrew if it exists (append last to ensure PATH precedence)
      if [[ -e /opt/homebrew/bin/brew ]]; then
        OLD_PATH="$PATH"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        export PATH="$OLD_PATH:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin"
      elif [[ -e /usr/local/bin/brew ]]; then
        OLD_PATH="$PATH"
        eval "$(/usr/local/bin/brew shellenv)"
        export PATH="$OLD_PATH:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin"
      fi
    '');

    programs.fish.interactiveShellInit = mkIf config.programs.fish.enable (mkAfter ''
      # Initialize homebrew if it exists (append last to ensure PATH precedence)
      if test -e /opt/homebrew/bin/brew
        # Run brew shellenv to get other environment variables (but not PATH yet)
        for line in (eval (/opt/homebrew/bin/brew shellenv) | string match -v 'set -gx PATH*')
          eval $line
        end
        # Remove any existing Homebrew paths from PATH, then append them at the end
        set -l clean_path
        for p in $PATH
          if not string match -q -r '^(/opt/homebrew|/usr/local/Homebrew)' $p
            set -a clean_path $p
          end
        end
        set -gx PATH $clean_path $HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin
      else if test -e /usr/local/bin/brew
        # Run brew shellenv to get other environment variables (but not PATH yet)
        for line in (eval (/usr/local/bin/brew shellenv) | string match -v 'set -gx PATH*')
          eval $line
        end
        # Remove any existing Homebrew paths from PATH, then append them at the end
        set -l clean_path
        for p in $PATH
          if not string match -q -r '^(/opt/homebrew|/usr/local/Homebrew)' $p
            set -a clean_path $p
          end
        end
        set -gx PATH $clean_path $HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin
      end
    '');

    programs.bash.initExtra = mkIf config.programs.bash.enable (mkAfter ''
      # Initialize homebrew if it exists (append last to ensure PATH precedence)
      if [[ -e /opt/homebrew/bin/brew ]]; then
        OLD_PATH="$PATH"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        export PATH="$OLD_PATH:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin"
      elif [[ -e /usr/local/bin/brew ]]; then
        OLD_PATH="$PATH"
        eval "$(/usr/local/bin/brew shellenv)"
        export PATH="$OLD_PATH:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin"
      fi
    '');
  };
}