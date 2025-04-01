{ config, lib, options, pkgs, ... }:
with builtins;
with lib;
let
  compilers = with pkgs; [ llvm ];
  tokyonight-main = pkgs.vimUtils.buildVimPlugin {
    pname = "tokyonight-main";
    version = "v3.0.1";
    src = pkgs.fetchFromGitHub {
      owner = "folke";
      repo = "tokyonight.nvim";
      rev = "v3.0.1";
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
    version = "v3.9.3";
    src = pkgs.fetchFromGitHub {
      owner = "EdenEast";
      repo = "nightfox.nvim";
      rev = "v3.9.3";
      sha256 = "";
    };
    meta.homepage = "https://github.com/EdenEast/nightfox.nvim";
  };
  plenary-main = pkgs.vimUtils.buildVimPlugin {
    pname = "plenary-main";
    pkgs.version = "v0.1.4";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "663246936325062427597964d81d30eaa42ab1e4";
      sha256 = "14j8jf1pvvszm9v75ykgf355gagdpf1rxmc3y04j2fnk8rz897bh";
    };
    meta.homepage = "https://github.com/williamboman/plenary-main";
  };
  mkUserNvimConfig = user: {
    home = {
      packages = with pkgs; [ github-copilot-cli ];
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
        diffview-nvim
        catppuccin-nvim
        neogit
        tokyonight-nvim
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
        nvim-treesitter
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
          xclip
          xsel
          lemonade
          ripgrep
          fd
          # nodePackages.vscode-json-languageserver
          tree-sitter
          fzf
          lua-language-server
          nodePackages.nodejs
          nodePackages.bash-language-server
          nodePackages.yaml-language-server
          nodePackages.eslint
          stylua
          shfmt
          nixd
          alejandra
          deadnix
          statix
          lua-language-server
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
  imports = [ ./mason.nix ./git.nix ./telescope.nix ./debug.nix ];
  config = { home-manager.users = nvim_configs; };
}
