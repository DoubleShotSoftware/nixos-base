# nixcats/languages/dotnet.nix - .NET/C# language support
# Uses pkgs.dotnetSDK, pkgs.easy-dotnet-tool from flake overlay
# Note: Roslyn LSP is now handled by easy-dotnet plugin (no longer need roslyn-ls/roslyn-nvim)
{ pkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    dotnetSDK              # From overlay
    # roslyn-ls           # Removed: easy-dotnet handles Roslyn LSP
    csharpier
    netcoredbg             # Fallback, easy-dotnet bundles its own
    dotnet-outdated
    dotnetPackages.Nuget
    dotnet-ef
    easy-dotnet-tool       # From overlay
  ];

  startupPlugins = with pkgs.vimPlugins; [
    easy-dotnet-nvim
    # roslyn-nvim         # Removed: using easy-dotnet built-in LSP
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
