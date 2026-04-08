# nixcats/languages/dotnet.nix - .NET/C# language support
# Uses pkgs.dotnetSDK from flake overlay
# easy-dotnet handles LSP (built-in roslyn), test runner, debugger, build
# easy-dotnet-server (dotnet-easydotnet) installed via dotnet tool, managed by systemd timer
{ pkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    dotnetSDK              # From overlay
    csharpier
    netcoredbg             # Fallback, easy-dotnet bundles its own
    dotnet-outdated
    dotnetPackages.Nuget
    dotnet-ef
  ];

  startupPlugins = [
    pkgs.customVimPlugins.easy-dotnet    # LSP, test runner, debugger, build
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

  # Pass tool paths to Lua
  extra = {
    csharpierPath = "${pkgs.csharpier}/bin/csharpier";
  };
}
