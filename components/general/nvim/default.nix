{ config, lib, options, pkgs, ... }:
with builtins;
with lib;
let
  compilers = with pkgs; [
    gcc
    clang
    zig
    llvm
    libstdcxx5

  ];
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
  nightfox = pkgs.vimUtils.buildVimPlugin {
    pname = "nightfox";
    version = "2023-02-17";
    src = pkgs.fetchFromGitHub {
      owner = "EdenEast";
      repo = "nightfox.nvim";
      rev = "68db77db88bf997f060cf591f81813ccba97c5e6";
      sha256 = "08gk1rga3w5fkjg37618g3mpkpba43rb0r5ckj9wpdgpvmm436y8";
    };
    meta.homepage = "https://github.com/EdenEast/nightfox.nvim";
  };
  plenary-main = pkgs.vimUtils.buildVimPlugin {
    pname = "plenary-main";
    pkgs.version = "2023-02-19";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-lua";
      repo = "plenary.nvim";
      rev = "bda256fab0eb66a15e8190937e417e6a14ee5d72";
      sha256 = "1qrdv9as2h591rgv47irz374rwndv0jgaia5a7x931j6j8zr0kkp";
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
      extraConfig = ''
        autocmd VimResized * wincmd =
        set laststatus=3
        set equalalways
        set foldmethod=expr
        set foldexpr=indent
        lua require('config_keymap')
        lua require('config_options')
        lua require('lsp')
      '';
      plugins = with pkgs.vimPlugins; [
        popup-nvim
        plenary-nvim
        {
          plugin = telescope-nvim;
          type = "lua";
          config = builtins.readFile (./config_telescope.lua);
        }
        {
          plugin = nvim-tree-lua;
          type = "lua";
          config = builtins.readFile (./config_nvim_tree.lua);
        }
        nvim-lsputils
        null-ls-nvim
        {
          plugin = nightfox-nvim;
          type = "lua";
          config = builtins.readFile (./config_nightfox.lua);
        }
        {
          plugin = nvim-lspconfig;
          type = "lua";
        }
        cmp-buffer
        cmp-path
        cmp-cmdline
        cmp_luasnip
        cmp-nvim-lsp
        cmp-calc
        cmp-emoji
        {
          plugin = nvim-treesitter;
          #.withPlugins (_: pkgs.tree-sitter.allGrammars);
          type = "lua";
          config = builtins.readFile (./config_treesitter.lua);
        }
        nvim-treesitter-refactor
        nvim-treesitter-context
        cmp-treesitter
        luasnip
        friendly-snippets
        nvim-cmp
        trouble-nvim
        SchemaStore-nvim
        {
          plugin = nvim-web-devicons;
          type = "lua";
          config = builtins.readFile (./config_nvim_web_devicons.lua);
        }
        {
          plugin = nvim-web-devicons;
          type = "lua";
          config = builtins.readFile (./config_nvim_web_devicons.lua);
        }
        {
          plugin = lualine-nvim;
          type = "lua";
          config = builtins.readFile (./config_lualine.lua);
        }
        {
          plugin = twilight-nvim;
          type = "lua";
          config = builtins.readFile (./config_twilight.lua);
        }
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = builtins.readFile (./config_gitsigns.lua);
        }
        {
          plugin = nvim-comment;
          type = "lua";
          config = builtins.readFile (./config_comment.lua);
        }
        {
          plugin = indent-blankline-nvim;
          type = "lua";
          config = builtins.readFile (./config_indent_blankline.lua);
        }
        lualine-lsp-progress
        {
          plugin = vim-which-key;
          config = builtins.readFile (./config_whichkey.vim);
        }
      ];
      extraPackages = with pkgs; [
        ripgrep
        nodePackages.vscode-json-languageserver
        tree-sitter
        fzf
        rnix-lsp
        lua-language-server
        nodePackages.bash-language-server
        nodePackages.yaml-language-server
        shfmt
      ] ++ compilers;
    };
    xdg.configFile."nvim/lua/config_options.lua".source = ./config_options.lua;
    xdg.configFile."nvim/lua/config_keymap.lua".source = ./config_keymap.lua;
    xdg.configFile."nvim/lua/config_nvim_web_devicons.lua".source =
      ./config_nvim_web_devicons.lua;
    xdg.configFile."nvim/lua/lsp" = {
      recursive = true;
      source = ./lsp;
    };
  };
  nvim_configs = mapAttrs
    (user: config:
      if (config.nvim) then
        (
          trace ''Enabling nvim for user: ${user}''
            mkUserNvimConfig
            user
        ) else { })
    (filterAttrs (user: userConfig: userConfig.userType != "system") config.personalConfig.users);
in
{ config = { home-manager.users = nvim_configs; }; }
