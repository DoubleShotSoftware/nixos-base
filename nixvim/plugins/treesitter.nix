# homepage: https://github.com/nvim-treesitter/nvim-treesitter
# nixvim doc: https://nix-community.github.io/nixvim/plugins/treesitter/index.html
{ lib, pkgs, ... }:

{
  opts = {
    # Enable treesitter syntax highlighting
    enable = true;
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      bash
      json
      lua
      make
      markdown
      nix
      regex
      toml
      vim
      vimdoc
      xml
      yaml
      typescript
      sql
      rust
      python
      nu
      jsdoc
      javascript
      http
      html
      dockerfile
      c-sharp
      hyprlang
    ];
    settings = {
      highlight = {
        additional_vim_regex_highlighting = true;
        enable = true;
      };
      incremental_selection = {
        enable = true;
        keymaps = {
          init_selection = false;
          node_decremental = "grm";
          node_incremental = "grn";
          scope_incremental = "grc";
        };
      };
      indent = { enable = true; };
    };
  };

  rootOpts = { };
}
