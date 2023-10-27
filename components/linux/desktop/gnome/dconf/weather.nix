# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/Weather" = {
      locations =
        "[<(uint32 2, <('New York City, Central Park', 'KNYC', false, [(0.71180344078725644, -1.2909618758762367)], @a(dd) [])>)>]";
    };

  };
}
