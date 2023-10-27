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
      package = pkgs.neovim-unwrapped;
      extraConfig = ''
        autocmd VimResized * wincmd =
        set laststatus=3
        set equalalways
        set foldmethod=indent
        lua require('config_keymap')
        lua require('config_options')
        lua require('lsp')
      '';
      plugins = with pkgs.vimPlugins; [
        popup-nvim
        plenary-nvim
        {
          plugin = nvim-lightbulb;
          type = "lua";
          config = builtins.readFile (./config_lightbulb.lua);
        }
        {
          plugin = lspkind-nvim;
          type = "lua";
          config = builtins.readFile (./config_lspkind.lua);
        }
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
          plugin = pkgs.unstable.vimPlugins.nvim-lspconfig;
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
        neoformat
      ];
      extraPackages = with pkgs.unstable; [
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
{
  imports = [
    ./mason
  ];
  config = {
    home-manager.users = nvim_configs;
  };
}
