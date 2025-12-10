# nixcats/languages/rust.nix - Rust language support
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    rust-analyzer
    rustfmt
    clippy
    cargo
    rustc
  ];

  startupPlugins = with pkgs.vimPlugins; [
    rustaceanvim
    crates-nvim
  ];

  optionalPlugins = with pkgs.vimPlugins; [
    nvim-dap
  ];

  environmentVariables = { };
}
