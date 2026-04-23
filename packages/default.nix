{ pkgs, dotnetSDK, ... }:

{
  resharper-cli = pkgs.callPackage ./resharper-cli.nix { inherit dotnetSDK; };
  cockpit-machines = pkgs.callPackage ./cockpit-machines.nix { };
  easy-dotnet-tool = pkgs.callPackage ./easy-dotnet-tool.nix { };
  kotlin-lsp = pkgs.callPackage ./kotlin-lsp.nix { };
  kotlinLsp = pkgs.callPackage ./kotlin-lsp.nix { };
  # Note: customVimPlugins is added directly in flake.nix overlay to avoid
  # overwriting nixpkgs vimPlugins
}
