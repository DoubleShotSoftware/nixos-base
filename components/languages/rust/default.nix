{ config, options, pkgs, ... }:

{
  home.packages = [
    pkgs.rust-analyzer
    pkgs.rustc
    pkgs.rustfmt
    pkgs.cargo
    pkgs.cargo-watch
    pkgs.cargo-deps
    pkgs.just
  ];
  programs.neovim = {
    extraPackages = [ pkgs.rust-analyzer pkgs.rustc pkgs.rustfmt pkgs.cargo ];
    plugins = with pkgs.vimPlugins; [
      crates-nvim
      {
        plugin = rust-tools-nvim;
        type = "lua";
        config = builtins.readFile (./config_rust_tools.lua);
      }
    ];
  };
}

