# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/shell/extensions/pop-shell" = {
      active-hint = true;
      active-hint-color = "rgba(122,162,247, 0.8)";
      gap-inner = mkUint32 10;
      gap-outer = mkUint32 10;
      hint-color-rgba = "rgba(122,162,247, 0.8)";
      smart-gaps = true;
      snap-to-grid = false;
      tile-by-default = true;
    };

  };
}
