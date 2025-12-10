{ pkgs, ... }:

{
  opts = {
    enable = true;
    package = pkgs.unstable.vimPlugins.snacks-nvim;
    settings = {
      notifier = {
        enabled = true;
        timeout = 3000;
      };
      #   lazygit = {
      #     enabled = true;
      #     configure = true;
      #     config = {
      #       os = { editPreset = "nvim-remote"; };
      #       gui = {
      #         # set to an empty string "" to disable icons
      #         nerdFontsVersion = "3";
      #       };
      #     };
      #   };
      #
    };
  };
  rootOpts = {
    extraPackages = with pkgs; [ lazygit ];
    keymaps = [
      {
        mode = "n";
        key = "<leader><space>";
        action.__raw = # lua
          "function() require('snacks').picker.smart() end";
        options.desc = "Smart Search";
      }
      {
        mode = "n";
        key = "<leader>fn";
        action.__raw = # lua
          "function() require('snacks').picker.notifications() end";
        options.desc = "[F]ind [N]otifications";
      }
      # Git
      {
        mode = "n";
        key = "<leader>gg";
        action.__raw = # lua
          "function() require('snacks').lazygit() end";
        options.desc = "LazyGit";
      }
      {
        mode = "n";
        key = "<leader>gb";
        action.__raw = # lua
          "function() require('snacks').picker.git_branches() end";
        options.desc = "[g]it [b]ranches";
      }
      {
        mode = "n";
        key = "<leader>gl";
        action.__raw = # lua
          "function() require('snacks').picker.git_log() end";
        options.desc = "[g]it [l]og";
      }
      {
        mode = "n";
        key = "<leader>gL";
        action.__raw = # lua
          "function() require('snacks').picker.git_log_line() end";
        options.desc = "[g]it log [L]ine";
      }
    ];
  };

}
