{ pkgs, ... }:

let version = "2.6.0";
in pkgs.vimUtils.buildVimPlugin {
  inherit version;

  name = "astroui";

  src = pkgs.fetchFromGitHub {
    owner = "astronvim";
    repo = "astroui";
    rev = "v${version}";
    hash = "sha256-kygFyXSIXQENWxGKgJAf5Aid5kfKWMsqTxckXbI6gyE=";
  };
}
