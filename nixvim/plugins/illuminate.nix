_:

{
  opts = {
    enable = true;
    settings = {
      delay = 200;
      filetypes_denylist = [ "dirbuf" "dirvish" "fugitive" "toggleterm" ];
      large_file_overrides = {
        providers = [ "lsp" ];
      };
      min_count_to_highlight = 2;
      large_file_cutoff = 2000;  # Set a reasonable large file cutoff (2000 lines)
      should_enable.__raw = ''
        function(bufnr)
          -- Simple buffer validation without astrocore
          if not vim.api.nvim_buf_is_valid(bufnr) then return false end
          local buftype = vim.bo[bufnr].buftype
          return buftype == "" or buftype == "help"
        end
      '';
    };
  };

  rootOpts.keymaps = [
    {
      mode = "n";
      key = "]r";
      action.__raw =
        "function() require('illuminate').goto_next_reference(false) end";
      options.desc = "Next reference";
    }
    {
      mode = "n";
      key = "[r";
      action.__raw =
        "function() require('illuminate').goto_prev_reference(false) end";
      options.desc = "Previous reference";
    }
    {
      mode = "n";
      key = "<leader>ur";
      action.__raw = "function() require('illuminate').toggle_buf() end";
      options.desc = "Toggle reference highlighting (buffer)";
    }
    {
      mode = "n";
      key = "<leader>uR";
      action.__raw = "function() require('illuminate').toggle() end";
      options.desc = "Toggle reference highlighting (global)";
    }
  ];
}
