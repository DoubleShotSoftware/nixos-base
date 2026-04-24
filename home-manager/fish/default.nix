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
  
  # Check if fish should be enabled for this user
  enableFish = (userConfig.shell or null) == "fish";
  
in {
  config = mkIf enableFish {
    programs = {
      fish = {
        enable = true;
        interactiveShellInit = ''
          ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
          set -U fish_greeting
          ${pkgs.fastfetch}/bin/fastfetch
          cd
        '';
        functions = {
          refresh = "source $HOME/.config/fish/config.fish";
          take = ''mkdir -p -- "$1" && cd -- "$1"'';
          ttake = "cd $(mktemp -d)";
          show_path = "echo $PATH | tr ' ' '\n'";
          posix-source = ''
            for i in (cat $argv)
              set arr (echo $i |tr = \n)
              set -gx $arr[1] $arr[2]
            end
          '';
        };
        shellAbbrs =
          {
            gc = "nix-collect-garbage --delete-old";
          }
          # navigation shortcuts
          // {
            ".." = "cd ..";
            "..." = "cd ../../";
            "...." = "cd ../../../";
            "....." = "cd ../../../../";
          }
          # git shortcuts
          // {
            gapa = "git add --patch";
            grpa = "git reset --patch";
            gst = "git status";
            gdh = "git diff HEAD";
            gp = "git push";
            gph = "git push -u origin HEAD";
            gco = "git checkout";
            gcob = "git checkout -b";
            gcm = "git checkout master";
            gcd = "git checkout develop";
            gsp = "git stash push -m";
            gsa = "git stash apply stash^{/";
            gsl = "git stash list";
          };
        shellAliases = {
          # e alias is handled by nvim module when nvim is enabled
          cat = "bat";
          jvim = "nvim";
          lvim = "nvim";
          pbcopy = "/mnt/c/Windows/System32/clip.exe";
          pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
          explorer = "/mnt/c/Windows/explorer.exe";
        };
        plugins = [
          {
            inherit (pkgs.fishPlugins.autopair) src;
            name = "autopair";
          }
          {
            inherit (pkgs.fishPlugins.done) src;
            name = "done";
          }
          {
            inherit (pkgs.fishPlugins.sponge) src;
            name = "sponge";
          }
        ];
      };
    };
    # Enable homebrew initialization on macOS
    programs.homebrew-init.enable = pkgs.stdenv.isDarwin;
  };
}
