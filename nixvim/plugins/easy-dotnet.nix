{ pkgs, dotnetSDK, ... }:
let
  # cmpRegister = # lua
  #   ''
  #     local cmp = require('cmp')
  #     cmp.register_source("easy-dotnet", require("easy-dotnet").package_completion_source)
  #   '';
  commonKey = # lua
    ''
      vim.keymap.set("n", "<leader>lbe", "<cmd>Dotnet<CR>", { buffer = true, desc = "Show Dotnet command picker" })
      vim.keymap.set("n", "<leader>lbb", "<cmd>Dotnet build quickfix<CR>", { buffer = true, desc = "Build with quickfix (with picker)" })
      vim.keymap.set("n", "<leader>lbr", "<cmd>Dotnet restore<CR>", { buffer = true, desc = "Run dotnet restore" })
      vim.keymap.set("n", "<leader>lbc", "<cmd>Dotnet clean<CR>", { buffer = true, desc = "Run dotnet clean" })
      vim.keymap.set("n", "<leader>lbt", "<cmd>Dotnet testrunner<CR>", { buffer = true, desc = "Open test runner" })
      vim.keymap.set("n", "<leader>lbf", "<cmd>split | terminal dotnet format<CR>", { buffer = true, desc = "Run dotnet format in terminal" })
    '';
in {
  opts = {
    enable = true;
    package = pkgs.unstable.vimPlugins.easy-dotnet-nvim;
    settings = {
      # Specify picker to avoid startup warning
      picker = "telescope";

      # Disable server features that might be causing issues
      server = {
        use_visual_studio = false;
      };

      # Terminal configuration for build output
      terminal.__raw = # lua
        ''
          function(path, action, args, ctx)
            args = args or ""
            local commands = {
              run = function() return string.format("%s %s", ctx.cmd, args) end,
              test = function() return string.format("%s %s", ctx.cmd, args) end,
              restore = function() return string.format("%s %s", ctx.cmd, args) end,
              build = function() return string.format("%s %s", ctx.cmd, args) end,
              watch = function() return string.format("dotnet watch --project %s %s", path, args) end,
            }
            local command = commands[action]()

            -- Show build output in a terminal
            vim.cmd("vsplit")
            vim.cmd("term " .. command)
          end
        '';


      # Disable auto-install to avoid startup errors
      auto_bootstrap_namespace = {
        enabled = false;
      };
    };
  };
  rootOpts = {
    extraPackages = with pkgs.unstable; [
      dotnetSDK  # Use the unified dotnetSDK from flake
      dotnet-outdated
      dotnetPackages.Nuget
      dotnet-ef
      netcoredbg
    ] ++ [
      # Add our custom packaged easy-dotnet-tool
      (pkgs.callPackage ../../packages/easy-dotnet-tool.nix { })
    ];

    # Ensure dotnet environment is properly configured
    extraConfigLuaPre = # lua
      ''
        -- Set DOTNET_ROOT for the easy-dotnet server
        vim.env.DOTNET_ROOT = "${dotnetSDK}/share/dotnet"
        vim.env.DOTNET_HOST_PATH = "${dotnetSDK}/bin/dotnet"

        -- Add dotnet tools to PATH (for user-installed global tools)
        local dotnet_tools_path = vim.fn.expand("~/.dotnet/tools")
        if vim.fn.isdirectory(dotnet_tools_path) == 1 then
          vim.env.PATH = dotnet_tools_path .. ":" .. vim.env.PATH
        end

        -- EasyDotnet tool is provided by Nix, so it's already in PATH
      '';
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
