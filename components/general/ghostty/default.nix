{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; let
  users = config.personalConfig.users;

  linuxOpts = ''
    linux-cgroup = single-instance
    linux-cgroup-memory-limit = 2147483648  # 2gb max
    linux-cgroup-processes-limit = 1000
    gtk-single-instance = desktop
  '';

  # Generate ghostty config for a user
  mkGhosttyConfig = user: userConfig:
    ''
      font-family = VictorMono Nerd Font Mono
      font-size = 13
      theme = Catppuccin Mocha
      shell-integration = detect
      shell-integration-features = cursor,sudo,title
      background-opacity = 0.85
      background-blur = false
      window-decoration = none
      keybind = shift+enter=text:\n
      # clipboard protection
      # prompts before programs read clipboard
      clipboard-read = ask
      # allows writing to clipboard
      clipboard-write = allow
      # warns about dangerous pastes (e.g., commands with newlines)
      clipboard-paste-protection = true
      # auto-copy selection
      copy-on-select = true
      # prevent title query attacks
      title-report = false
    ''
    + optionalString pkgs.stdenv.isLinux linuxOpts;
in {
  config = {
    home-manager.users = mapAttrs (
      user: userConfig:
        if userConfig.ghostty
        then {
          home.packages = [pkgs.ghostty];
          home.file.".config/ghostty/config".text = mkGhosttyConfig user userConfig;
        }
        else {}
    ) (filterAttrs (user: userConfig: userConfig.userType != "system") users);
  };
}
