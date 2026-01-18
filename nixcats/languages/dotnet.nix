# nixcats/languages/dotnet.nix - .NET/C# language support
# Uses pkgs.dotnetSDK, pkgs.easy-dotnet-tool from flake overlay
# Note: roslyn-nvim for LSP (better diagnostics), easy-dotnet for test/debug/build
{ pkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    dotnetSDK              # From overlay
    roslyn-ls              # Roslyn language server
    csharpier
    netcoredbg             # Fallback, easy-dotnet bundles its own
    dotnet-outdated
    dotnetPackages.Nuget
    dotnet-ef
    easy-dotnet-tool       # From overlay
  ];

  startupPlugins = with pkgs.vimPlugins; [
    easy-dotnet-nvim       # Test runner, debugger, build commands
    roslyn-nvim            # LSP client (better diagnostic responsiveness)
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

  # Pass tool paths to Lua for conform formatter config
  extra = {
    csharpierPath = "${pkgs.csharpier}/bin/csharpier";
  };
}
