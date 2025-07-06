{ pkgs, ... }: {
  opts = {
    enable = true;
    package = pkgs.unstable.vimPlugins.noice-nvim;
  };
  rootOpts = { };
}
