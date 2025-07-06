{ pkgs, ... }:
let
  version = "6e9dd545a1af204c4022a8fcd99727ea41ffdcc8";
  nvim-lint = pkgs.vimUtils.buildVimPlugin {
    inherit version;
    name = "roslyn.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "mfussenegger";
      repo = "nvim-lint";
      rev = version;
      hash = "";
    };
  };
in {
  extraPlugins = [ nvim-lint ];
  extraPackages = with pkgs; [ vale deadnix ];
  extraConfigLuaPost = builtins.readFile ../lua/nvim-lint.lua;
  keymaps = [ ];
}
