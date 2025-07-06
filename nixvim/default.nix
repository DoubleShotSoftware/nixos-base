{ pkgs, lib, ... }: {

  imports = [ ./custom ./config ./plugins ./utils ./options.nix ];
  config = {
    #package = pkgs.unstable.neovim-unwrapped;
    editorconfig.enable = true;
    # Use <Space> as leader key
    globals.mapleader = " ";
    extraConfigLua = ''
      vim.api.nvim_set_hl(0, "CmpItemAbbrSemiboldUnderline", {
        bold = true,
        underline = true,
      })
      vim.api.nvim_set_hl(0, "CmpItemKindLightItalic", {
        italic = true,
      })
      ${builtins.readFile ./lua/utils.lua}

      -- Explicitly add lua directory to runtime path
      vim.opt.runtimepath:append(vim.fn.stdpath('config') .. '/lua')
    '';
    # Set 'vi' and 'vim' aliases to nixvim
    viAlias = true;
    vimAlias = true;
    # Setup clipboard support
    clipboard = {
      # Use xsel as clipboard provider
      providers.xsel.enable = true;
      # Sync system clipboard
      register = "unnamedplus";
    };
    extraPackages = with pkgs; [ gcc clang cmake zig ];
    extraPlugins = with pkgs.vimPlugins; [
      lspkind-nvim
      mini-icons
      vim-devicons
      nvim-web-devicons
      nvim-nonicons
      nui-nvim
    ];
  };
}
