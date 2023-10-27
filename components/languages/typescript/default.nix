{ config, options, pkgs, ... }:
let
  cmp-npm = pkgs.vimUtils.buildVimPlugin {
    pname = "cmp-npm";
    version = "2021-10-27";
    src = pkgs.fetchFromGitHub {
      owner = "David-Kunz";
      repo = "cmp-npm";
      rev = "4b6166c3feeaf8dae162e33ee319dc5880e44a29";
      sha256 = "0lkrbj5pswyb161hi424bii394qfdhm7v86x18a5fs2cmkwi0222";
    };
    meta.homepage = "https://github.com/David-Kunz/cmp-npm";
  };
in {
  home.packages = with pkgs; [
    nodejs
    yarn
    nodePackages.npm
    nodePackages.typescript
    nodePackages.vscode-langservers-extracted
    nodePackages.typescript-language-server
  ];
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [ cmp-npm ];
    extraPackages = with pkgs; [
      tree-sitter-grammars.tree-sitter-tsx
      tree-sitter-grammars.tree-sitter-typescript
      tree-sitter-grammars.tree-sitter-javascript
    ];
    extraConfig = ''
      lua require('lsp.settings.typescript')
    '';
  };
  xdg.configFile."nvim/lua/lsp/settings/typescript.lua".source =
    ./typescript.lua;
  xdg.configFile."nvim/lua/lsp/cmp-sources/npm.lua".text = ''
    	local M = {}
    	M.methods = {}
    	require('cmp-npm').setup({})
    	function M.source(sources) 
            	table.insert(sources,     { name = 'npm', keyword_length = 4 } )
            end
    	return M
  '';
  xdg.configFile."nvim/lua/lsp/treesitter/typescript.lua".text = ''
    	local M = {}
    	M.methods = {}
            local ts_utils = require('nvim-treesitter.ts_utils')
    	function M.add_language(languages) 
            	table.insert(languages, { 
    			"javascript",
    			"jsdoc",
    			"tsx",
    			"typescript"	
    		})
            end
    	return M
  '';

  programs.zsh = {
    initExtra = ''
            	if [ ! -f $HOME/.npm-global ];
              then
            		mkdir -p $HOME/.npm-global
            	fi
      	      npm config set prefix '$HOME/.npm-global'
    '';
    oh-my-zsh = { plugins = [ "npm" "node" "yarn" ]; };

  };
}
