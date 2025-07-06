{ ... }: {
  config.globals = {
    mapleader = " ";
    maplocalleader = " ";
  };
  config.keymaps = [
    {
      mode = "";
      key = "<Space>";
      action = "<Nop>";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>bc";
      action = ":bdelete<CR>";
      options = { desc = "Close the current buffer"; };
    }
    {
      mode = "n";
      key = "<leader>bC";
      action = ":bdelete!<CR>";
      options = { desc = "Force close the current buffer"; };
    }
    # Window navigation
    {
      action = "<C-w>h";
      key = "<C-h>";
      mode = "n";
      options = {
        noremap = true;
        silent = true;
        desc = "Move to the window on the left";
      };
    }
    {
      action = "<C-w>j";
      key = "<C-j>";
      mode = "n";
      options = {
        noremap = true;
        silent = true;
        desc = "Move to the window below";
      };
    }
    {
      action = "<C-w>k";
      key = "<C-k>";
      mode = "n";
      options = {
        noremap = true;
        silent = true;
        desc = "Move to the window above";
      };
    }
    {
      action = "<C-w>l";
      key = "<C-l>";
      mode = "n";
      options = {
        noremap = true;
        silent = true;
        desc = "Move to the window on the right";
      };
    }
    # Tab navigation
    {
      action = "<cmd>tabprevious<CR>";
      key = "[t";
      mode = "n";
      options = {
        noremap = true;
        silent = true;
        desc = "previous tab";
      };
    }
    {
      action = "<cmd>tabnext<CR>";
      key = "]t";
      mode = "n";
      options = {
        noremap = true;
        silent = true;
        desc = "next tab";
      };
    }
    # Resize window with Ctrl + arrow keys
    {
      action = "<cmd>resize +4<CR>";
      key = "<C-Up>";
      mode = "n";
      options = {
        noremap = true;
        silent = true;
        desc = "Increase window height";
      };
    }
    {
      action = "<cmd>resize -4<CR>";
      key = "<C-Down>";
      mode = "n";
      options = {
        noremap = true;
        silent = true;
        desc = "Decrease window height";
      };
    }
    {
      action = "<cmd>vertical resize +4<CR>";
      key = "<C-Left>";
      mode = "n";
      options = {
        noremap = true;
        silent = true;
        desc = "Increase window width";
      };
    }
    {
      action = "<cmd>vertical resize -4<CR>";
      key = "<C-Right>";
      mode = "n";
      options = {
        noremap = true;
        silent = true;
        desc = "Decrease window width";
      };
    }
    # Move text up and down
    {
      action = "<cmd>move .+1<CR>==";
      key = "<A-j>";
      mode = "n";
      options = {
        noremap = true;
        silent = true;
        desc = "Move line down";
      };
    }
    {
      action = "<cmd>move .-2<CR>==";
      key = "<A-k>";
      mode = "n";
      options = {
        noremap = true;
        silent = true;
        desc = "Move line up";
      };
    }
    # Stay in visual mode while indenting
    {
      action = "<gv";
      key = "<";
      mode = "v";
      options = {
        noremap = true;
        silent = true;
        desc = "Indent left";
      };
    }
    {
      action = ">gv";
      key = ">";
      mode = "v";
      options = {
        noremap = true;
        silent = true;
        desc = "Indent right";
      };
    }
    # Move text up and down in visual mode
    {
      action = ":move '>+1<CR>gv=gv";
      key = "<A-j>";
      mode = "v";
      options = {
        noremap = true;
        silent = true;
        desc = "Move line down";
      };
    }
    {
      action = ":move '<-2<CR>gv=gv";
      key = "<A-k>";
      mode = "v";
      options = {
        noremap = true;
        silent = true;
        desc = "Move line up";
      };
    }
  ];
}
