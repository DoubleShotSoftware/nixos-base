{ config, lib, pkgs, ... }:
with lib;
with builtins;
let
  users = config.personalConfig.users;
  desktopEnabled = any
    (userConfig: userConfig.desktop != "disabled")
    (mapAttrsToList (user: userConfig: userConfig) users);
in
{
  config = lib.mkIf desktopEnabled {
    # Add themes and libadwaita compatibility
    environment.systemPackages = with pkgs; [
      adw-gtk3
      tokyonight-gtk-theme
      nordic
      catppuccin-gtk
      catppuccin-cursors
    ];

    # Set GTK theme environment variable for better compatibility
    # Disabled - let GNOME Tweaks handle theme selection
    # environment.sessionVariables = {
    #   GTK_THEME = "catppuccin-frappe-blue-standard";
    # };

    # Create flatpak theme directories and symlinks
    system.userActivationScripts = {
      flatpakThemes = {
        text = ''
          # Create flatpak theme directories if they don't exist
          if [ ! -d "$HOME/.local/share/themes" ]; then
            mkdir -p "$HOME/.local/share/themes"
          fi
          if [ ! -d "$HOME/.local/share/icons" ]; then
            mkdir -p "$HOME/.local/share/icons"
          fi

          # Link Tokyo Night and Nordic themes for flatpak access
          # Check if theme doesn't already exist before linking
          if [ ! -e "$HOME/.local/share/themes/Tokyonight-Dark" ]; then
            ln -sf "${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Dark" "$HOME/.local/share/themes/" 2>/dev/null || true
          fi
          if [ ! -e "$HOME/.local/share/themes/Tokyonight-Dark-B" ]; then
            ln -sf "${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Dark-B" "$HOME/.local/share/themes/" 2>/dev/null || true
          fi
          if [ ! -e "$HOME/.local/share/themes/Tokyonight-Dark-BL" ]; then
            ln -sf "${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Dark-BL" "$HOME/.local/share/themes/" 2>/dev/null || true
          fi

          # Link Nordic icons and cursors
          if [ ! -e "$HOME/.local/share/icons/Nordic" ]; then
            ln -sf "${pkgs.nordic}/share/icons/Nordic" "$HOME/.local/share/icons/" 2>/dev/null || true
          fi
          if [ ! -e "$HOME/.local/share/icons/Nordic-darker" ]; then
            ln -sf "${pkgs.nordic}/share/icons/Nordic-darker" "$HOME/.local/share/icons/" 2>/dev/null || true
          fi
          if [ ! -e "$HOME/.local/share/icons/Nordic-cursors" ]; then
            ln -sf "${pkgs.nordic}/share/icons/Nordic-cursors" "$HOME/.local/share/icons/" 2>/dev/null || true
          fi

          # Set flatpak overrides for theme access (if flatpak is installed)
          if command -v flatpak >/dev/null 2>&1; then
            # Allow flatpak apps to access theme directories
            flatpak override --user --filesystem=~/.local/share/themes:ro 2>/dev/null || true
            flatpak override --user --filesystem=~/.local/share/icons:ro 2>/dev/null || true
            flatpak override --user --filesystem=/nix/store:ro 2>/dev/null || true

            # Set theme environment variables for flatpak apps
            flatpak override --user --env=GTK_THEME=Tokyonight-Dark 2>/dev/null || true
            flatpak override --user --env=ICON_THEME=Nordic-darker 2>/dev/null || true
            flatpak override --user --env=CURSOR_THEME=Nordic-cursors 2>/dev/null || true
          fi
        '';
      };
    };

    # Configure dconf settings for GNOME
    home-manager.users = mapAttrs (user: userConfig:
      if (userConfig.desktop == "gnome") then {
        # Temporarily disabled - user will configure themes manually
        # dconf.settings = {
        #   "org/gnome/shell/extensions/user-theme" = {
        #     name = "catppuccin-frappe-blue-standard";
        #   };
        #   "org/gnome/desktop/interface" = {
        #     gtk-theme = "catppuccin-frappe-blue-standard";
        #     icon-theme = "Arc";
        #     cursor-theme = "catppuccin-mocha-blue-cursors";
        #     color-scheme = "prefer-dark";
        #   };
        #   "org/gnome/desktop/wm/preferences" = {
        #     theme = "catppuccin-frappe-blue-standard";
        #   };
        # };
      } else if (userConfig.desktop != "disabled") then {
        # Qt theme compatibility for non-GNOME desktops
        qt = {
          enable = true;
          platformTheme.name = "gtk";
          style.name = "gtk2";
        };
      } else {})
      (filterAttrs (user: userConfig: userConfig.userType != "system") users);
  };
}