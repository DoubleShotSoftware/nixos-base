{ pkgs, ... }: {
  opts = {
    enable = true;
  };
  # rootOpts = {
  #   keymaps = [
  #     {
  #       mode = "n";
  #       key = "<leader>gl";
  #       action.__raw = ":LazyGit<CR>";
  #       options.desc = "Launch Lazy Git";
  #     }
  #     {
  #       mode = "n";
  #       key = "<leader>gB";
  #       action.__raw = ":LazyGitCurrentFile<CR>";
  #       options.desc = "Lazy Git Buffer";
  #     }
  #   ];
  #
  # };
}
