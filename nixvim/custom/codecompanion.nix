{ pkgs, ... }: {

  extraPlugins = with pkgs.unstable.vimPlugins; [ codecompanion-nvim ];
  extraConfigLuaPost = builtins.readFile ../lua/codecompanion.lua;
}
