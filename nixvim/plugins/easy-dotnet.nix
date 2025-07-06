{ pkgs, ... }:
let
  # cmpRegister = # lua
  #   ''
  #     local cmp = require('cmp')
  #     cmp.register_source("easy-dotnet", require("easy-dotnet").package_completion_source)
  #   '';
  commonKey = # lua
    ''
      vim.keymap.set("n", "<leader>lbe", "<cmd>DotnetUI<CR>", { buffer = true, desc = "Show Easy Dotnet UI" })
      vim.keymap.set("n", "<leader>lbb", "<cmd>Dotnet build quickfix<CR>", { buffer = true, desc = "Run dotnet build with quick fix" })
      vim.keymap.set("n", "<leader>lbr", "<cmd>Dotnet restore<CR>", { buffer = true, desc = "Run dotnet restore" })
      vim.keymap.set("n", "<leader>lbc", "<cmd>Dotnet clean<CR>", { buffer = true, desc = "Run dotnet clean" })
      vim.keymap.set("n", "<leader>lbf", "<cmd>split | terminal dotnet format<CR>", { buffer = true, desc = "Run dotnet format in terminal" })
    '';
in {
  opts = {
    enable = true;
    package = pkgs.unstable.vimPlugins.easy-dotnet-nvim;
    settings = { };
  };
  rootOpts = {
    extraPackages = with pkgs.unstable; [
      dotnet-outdated
      dotnetPackages.Nuget
      dotnet-ef
      netcoredbg
    ];
    extraFiles = {
      "ftdetect/natural.vim" = {
        source = ../passthrough/ftdetect/natural.vim;
      };
      "syntax/natural.vim" = { source = ../passthrough/syntax/natural.vim; };
      "after/ftplugin/csproj.lua" = {
        text = # lua
          ''
            ${commonKey}
          '';
      };
      "after/ftplugin/cs.lua" = {
        text = # lua
          ''
            ${commonKey}
          '';

      };
    };
  };
}
