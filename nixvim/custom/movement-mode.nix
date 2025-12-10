{ pkgs, ... }:
let
  # Create a plugin for movement-mode
  movement-mode = pkgs.vimUtils.buildVimPlugin {
    name = "movement-mode.nvim";
    src = pkgs.stdenv.mkDerivation {
      name = "movement-mode-src";
      src = ./.;
      installPhase = ''
        mkdir -p $out/lua
        cp ${../lua/movement-mode.lua} $out/lua/movement-mode.lua
      '';
    };
  };
in {
  # Add our plugin to extraPlugins
  extraPlugins = [ movement-mode ];

  # Configure the plugin
  extraConfigLuaPost = ''
    -- Initialize the movement mode
    require("movement-mode").setup()

    -- Add a status component for Noice to show movement mode status
    local has_noice, noice = pcall(require, "noice")
    if has_noice then
      local status_opts = {
        kind = "movement_mode",
        format = function()
          local movement_mode = require("movement-mode")
          return movement_mode.is_active() and "MVT" or ""
        end
      }

      -- Try to add to the status line
      pcall(function()
        table.insert(require("noice.config").status, status_opts)
      end)
    end
  '';
}