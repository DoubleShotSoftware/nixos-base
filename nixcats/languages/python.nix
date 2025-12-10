# nixcats/languages/python.nix - Python language support
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    pyright
    ruff
    black
    isort
    python3
  ];

  startupPlugins = with pkgs.vimPlugins; [
    # nvim-lspconfig handles pyright
  ];

  optionalPlugins = with pkgs.vimPlugins; [
    nvim-dap
    nvim-dap-python
  ];

  environmentVariables = { };
}
