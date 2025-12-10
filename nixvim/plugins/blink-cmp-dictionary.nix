{pkgs, ...}:

{
  opts = {
    enable = true;
    package = pkgs.unstable.vimPlugins.blink-cmp-spell;
  };
  rootOpts = { };
}
