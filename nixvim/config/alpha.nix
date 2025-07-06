{ pkgs, ... }: {
  extraPlugins = with pkgs.vimPlugins; [ alpha-nvim ];

  extraConfigLua = builtins.readFile ../lua/alpha.lua;
}
