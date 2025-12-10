{ pkgs, ... }: {
  extraPlugins = with pkgs.vimPlugins; [ neoformat ];
  extraConfigLuaPost = builtins.readFile ../lua/neoformat.lua;
  extraPackages = with pkgs; [ stylua luaformatter libxml2 ];
  keymaps = [{
    mode = "n";
    key = "<leader>bf";
    action = ":Neoformat<CR>";
    options = { desc = "Format the current buffer"; };
  }];
}
