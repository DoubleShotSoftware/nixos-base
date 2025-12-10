# homepage: https://github.com/stevearc/resession.nvim
{ lib, pkgs, ... }:

{
  extra = {
    packages = [ (import ./package.nix { inherit lib pkgs; }) ];

    # Simple resession config without AstroNvim dependencies
    config = ''
      require("resession").setup({
        -- Buffer filter to determine what buffers to save
        buf_filter = function(bufnr)
          local buftype = vim.bo[bufnr].buftype
          local filetype = vim.bo[bufnr].filetype

          -- Skip special buffer types
          if buftype ~= "" and buftype ~= "acwrite" then
            return false
          end

          -- Skip these filetypes
          local skip_ft = {
            "gitcommit", "gitrebase", "svn", "hgcommit",
            "neo-tree", "neo-tree-popup", "alpha", "dashboard",
            "Trouble", "lazy", "mason", "notify", "toggleterm"
          }
          if vim.tbl_contains(skip_ft, filetype) then
            return false
          end

          -- Only save buffers with actual files
          return vim.api.nvim_buf_get_name(bufnr) ~= ""
        end,
        -- Don't use complex tab filtering
        tab_buf_filter = function(tabpage, bufnr)
          return true
        end,
      })
    '';
  };

  rootOpts = {
    autoGroups.resession = { };
    autoCmd = [{
      desc = "Save session on close";
      event = "VimLeavePre";
      group = "resession";

      # Simple autosave without astrocore dependency
      callback.__raw = ''
        function()
          -- Always save the "last" session on exit
          local save = require("resession").save
          save("last", { notify = false })

          -- Also save a session for the current working directory
          local cwd = vim.fn.getcwd()
          if cwd and cwd ~= "" then
            save(cwd, { dir = "dirsession", notify = false })
          end
        end
      '';
    }];

    keymaps = [
      {
        mode = "n";
        key = "<leader>sl";
        action.__raw = "function() require('resession').load 'last' end";
        options.desc = "Load last session";
      }
      {
        mode = "n";
        key = "<leader>ss";
        action.__raw = "function() require('resession').save() end";
        options.desc = "Save this session";
      }
      {
        mode = "n";
        key = "<leader>sS";
        action.__raw =
          "function() require('resession').save(vim.fn.getcwd(), { dir = 'dirsession' }) end";
        options.desc = "Save this dirsession";
      }
      {
        mode = "n";
        key = "<leader>st";
        action.__raw = "function() require('resession').save_tab() end";
        options.desc = "Save this tab's session";
      }
      {
        mode = "n";
        key = "<leader>sd";
        action.__raw = "function() require('resession').delete() end";
        options.desc = "Delete a session";
      }
      {
        mode = "n";
        key = "<leader>sD";
        action.__raw =
          "function() require('resession').delete(nil, { dir = 'dirsession' }) end";
        options.desc = "Delete a dirsession";
      }
      {
        mode = "n";
        key = "<leader>sf";
        action.__raw = "function() require('resession').load() end";
        options.desc = "Load a session";
      }
      {
        mode = "n";
        key = "<leader>sF";
        action.__raw =
          "function() require('resession').load(nil, { dir = 'dirsession' }) end";
        options.desc = "Load a dirsession";
      }
      {
        mode = "n";
        key = "<leader>s.";
        action.__raw =
          "function() require('resession').load(vim.fn.getcwd(), { dir = 'dirsession' }) end";
        options.desc = "Load current dirsession";
      }
    ];
  };
}
