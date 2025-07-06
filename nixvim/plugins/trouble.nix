_: {
  opts = { enable = true; };
  rootOpts.keymaps = [{
    mode = "n";
    key = "<leader>lx";
    action = ":Trouble diagnostics toggle focus=false filter.buf=0<CR>";
    options = { desc = "Diagnostics"; };
  }];

}
