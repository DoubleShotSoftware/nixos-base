{ pkgs, dotnetSDK, ... }:

{
  resharper-cli = pkgs.callPackage ./resharper-cli.nix { inherit dotnetSDK; };
  cockpit-machines = pkgs.callPackage ./cockpit-machines.nix { };
  easy-dotnet-tool = pkgs.callPackage ./easy-dotnet-tool.nix { };
  # Note: customVimPlugins is added directly in flake.nix overlay to avoid
  # overwriting nixpkgs vimPlugins
}