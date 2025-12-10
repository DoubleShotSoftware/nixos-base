# nixcats/languages/dotnet.nix - .NET/C# language support
# Uses pkgs.dotnetSDK, pkgs.customVimPlugins, pkgs.easy-dotnet-tool from flake overlay
{ pkgs, stablePkgs, ... }:
let
  # Use stable roslyn-ls to avoid breakage
  roslyn-ls = stablePkgs.roslyn-ls or pkgs.roslyn-ls;
in
{
  lspsAndRuntimeDeps = with pkgs; [
    dotnetSDK              # From overlay
    roslyn-ls
    csharpier
    netcoredbg
    dotnet-outdated
    dotnetPackages.Nuget
    dotnet-ef
    easy-dotnet-tool       # From overlay
  ];

  startupPlugins = (with pkgs.vimPlugins; [
    easy-dotnet-nvim
  ]) ++ [
    pkgs.customVimPlugins.roslyn-nvim  # From overlay
  ];

  optionalPlugins = with pkgs.vimPlugins; [
    nvim-dap
    nvim-dap-ui
    nvim-dap-virtual-text
  ];

  environmentVariables = {
    DOTNET_ROOT = "${pkgs.dotnetSDK}/share/dotnet";
    DOTNET_HOST_PATH = "${pkgs.dotnetSDK}/bin/dotnet";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };

  # Pass paths for Lua config via nixCats.extra
  extra = {
    roslynDLLPath = "${roslyn-ls}/lib/roslyn-ls/Microsoft.CodeAnalysis.LanguageServer.dll";
    roslynDotnetPath = "${pkgs.dotnetSDK}/bin/dotnet";
  };
}
