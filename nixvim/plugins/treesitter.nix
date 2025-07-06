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
      kotlin
      jsdoc
      javascript
      http
      html
      dockerfile
      c-sharp
    ];
    settings = {
      auto_install = true;
      ensure_installed =
        [ "c_sharp" "bash" "dockerfile" "typescript" "python" ];
      highlight = {
        additional_vim_regex_highlighting = true;
        custom_captures = { };
        disable = [ ];
        enable = true;
      };
      ignore_install = [ ];
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
      parser_install_dir = {
        __raw = "vim.fs.joinpath(vim.fn.stdpath('data'), 'treesitter')";
      };
      sync_install = false;
    };
  };

  rootOpts = { };
}
