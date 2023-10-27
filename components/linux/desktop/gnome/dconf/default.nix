{ lib, ... }:

with lib.hm.gvariant; {
  imports = [
    ./custom-keybindings.nix
    ./mutter.nix
    ./pop-shell.nix
    ./weather.nix
    ./wm.nix
    ./wm-preferences.nix
  ];
}
