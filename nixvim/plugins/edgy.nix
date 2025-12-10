{ pkgs, ... }: {
  opts = {
    enable = true;
    package = pkgs.unstable.vimPlugins.edgy-nvim;
  };
  rootOpts = { };
}
