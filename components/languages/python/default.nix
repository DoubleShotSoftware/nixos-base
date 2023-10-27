{ config, options, pkgs, ... }: {
  home.packages = with pkgs; [ black pipenv python310Packages.pip ];
  programs = {
    neovim = {
      extraPackages = with pkgs; [
        tree-sitter-grammars.tree-sitter-python
        nodePackages.pyright
      ];
      extraConfig = ''
        lua require('lsp.settings.python')
      '';
    };
    zsh = {
      initExtra = "";
      oh-my-zsh = { plugins = [ "python" "pylint" "pyenv" "poetry" ]; };
    };
  };
  xdg.configFile = {
    "nvim/lua/lsp/settings/python.lua".source = ./python.lua;
    "nvim/lua/lsp/treesitter/python.lua".text = ''
      	local M = {}
      	M.methods = {}
              local ts_utils = require('nvim-treesitter.ts_utils')
      	function M.add_language(languages) 
          table.insert(languages, { 
      			"python"	
      		})
        end
      	return M
    '';
  };

}
