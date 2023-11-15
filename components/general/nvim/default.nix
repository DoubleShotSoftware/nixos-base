{ config, lib, options, pkgs, ... }:
with builtins;
with lib;
let
  compilers = with pkgs; [ gcc clang zig llvm libstdcxx5 ];
  tokyonight-main = pkgs.vimUtils.buildVimPlugin {
    pname = "tokyonight-main";
    version = "2023-03-14";
    src = pkgs.fetchFromGitHub {
      owner = "folke";
      repo = "tokyonight.nvim";
      rev = "a0a7bfbc4c54348b56880a162afac9d103c618c1";
      sha256 = "07l8x4za6j444dd7bwwllk1sadhvnlshmjwz01xlympqsb6j8hz9";
    };
    meta.homepage = "https://github.com/folke/tokyonight.nvim/";
  };
  whichkey = pkgs.vimUtils.buildVimPlugin {
    pname = "whichkey";
    version = "v1.6.0";
    src = pkgs.fetchFromGitHub {
      owner = "folke";
      repo = "which-key.nvim";
      rev = "ce741eb559c924d72e3a67d2189ad3771a231414";
      sha256 = "EVGIe8wUoKdND40vuyqT6+EOY6aUFBpY8PXivvL3ZZM=";
    };
    meta.homepage = "https://github.com/folke/which-key.nvim";
  };
  nightfox = pkgs.vimUtils.buildVimPlugin {
    pname = "nightfox";
    version = "v3.6.1";
    src = pkgs.fetchFromGitHub {
      owner = "EdenEast";
      repo = "nightfox.nvim";
      rev = "v3.6.1";
      sha256 = "0d7c74fip5xk81ypihl0yjb9mfcdry0spq7c8zs2zsrm6a9xbxzy";
    };
    meta.homepage = "https://github.com/EdenEast/nightfox.nvim";
  };
  plenary-main = pkgs.vimUtils.buildVimPlugin {
    pname = "plenary-main";
    pkgs.version = "v0.1.4";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "v0.1.4";
      sha256 = "14j8jf1pvvszm9v75ykgf355gagdpf1rxmc3y04j2fnk8rz897bh";
    };
    meta.homepage = "https://github.com/williamboman/plenary-main";
  };
  mkUserNvimConfig = user: {
    home = {
      shellAliases = {
        e = "nvim";
        vim = "nvim";
        vi = "nvim";
      };
      sessionVariables = { EDITOR = "nvim"; };
    };
    programs.zsh.sessionVariables = { EDITOR = "nvim"; };
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      package = pkgs.unstable.neovim-unwrapped;
      extraLuaConfig = builtins.readFile (./init.lua);
      plugins = with pkgs.unstable.vimPlugins; [
        popup-nvim
        plenary-nvim
        whichkey
        nvim-lightbulb
        lspkind-nvim
        nvim-tree-lua
        nvim-lsputils
        null-ls-nvim
        nightfox-nvim
        nvim-lspconfig
        cmp-buffer
        cmp-path
        cmp-cmdline
        cmp_luasnip
        cmp-nvim-lsp
        cmp-calc
        cmp-emoji
        nvim-treesitter.withAllGrammars
        fidget-nvim
        nvim-treesitter-refactor
        nvim-treesitter-context
        nvim-treesitter-textobjects
        cmp-treesitter
        luasnip
        friendly-snippets
        nvim-cmp
        trouble-nvim
        SchemaStore-nvim
        nvim-web-devicons
        lualine-nvim
        twilight-nvim
        comment-nvim
        indent-blankline-nvim
        lualine-lsp-progress
        vim-which-key
        neoformat
        neodev-nvim
        alpha-nvim
        persistence-nvim
        harpoon
        undotree
	lightspeed-nvim
      ];
      extraPackages = with pkgs.unstable;
        [
          ripgrep
          fd
          nodePackages.vscode-json-languageserver
          tree-sitter
          fzf
          lua-language-server
          nodejs_18
          nodePackages.bash-language-server
          nodePackages.yaml-language-server
          nodePackages.eslint
          stylua
          shfmt
          nixd
        ] ++ compilers;
    };
    xdg.configFile."nvim/lua/user" = {
      recursive = true;
      source = ./lua;
    };
  };
  nvim_configs = mapAttrs (user: config:
    if (config.nvim) then
      (trace "Enabling nvim for user: ${user}" mkUserNvimConfig user)
    else
      { }) (filterAttrs (user: userConfig: userConfig.userType != "system")
        config.personalConfig.users);
in {
  imports = [ ./mason ./git ./telescope ];
  config = { home-manager.users = nvim_configs; };
}
