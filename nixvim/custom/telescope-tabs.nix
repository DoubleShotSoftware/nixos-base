{ pkgs, ... }:
let
  telescope-tabs = pkgs.vimUtils.buildVimPlugin {
    name = "telescope-tabs";
    src = pkgs.fetchFromGitHub {
      owner = "LukasPietzschmann";
      repo = "telescope-tabs";
      rev = "9ca0800d4e9c2610d5cac4d121cde0d9fbd89a64";
      hash = "sha256-++iTyrjl6IX2GmwljbgcwiYvZ3ghsX732VWMcyu1ciw=";
    };
    dependencies = with pkgs.vimPlugins; [ telescope-nvim plenary-nvim ];

  };
in {
  extraPlugins = [ telescope-tabs ];
  keymaps = [{
    mode = "n";
    key = "<leader>ft";
    action = ":Telescope telescope-tabs list_tabs<CR>";
    options.desc = "Find Tabs";
  }];
}
