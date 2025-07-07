# Dotnet language configuration function
{ pkgs }:
let
  dotnetSDK = with pkgs;
    dotnetCorePackages.combinePackages [
      dotnetCorePackages.sdk_6_0_1xx
      dotnetCorePackages.sdk_7_0_3xx
      dotnetCorePackages.dotnet_8.sdk
      dotnetCorePackages.dotnet_9.sdk
      dotnetCorePackages.sdk_10_0-bin
    ];
in
{
  packages = with pkgs; [
    dotnetPackages.Nuget
    dotnetPackages.NUnit
    dotnetSDK
    resharper-cli
  ];
  sessionVariables = {
    DOTNET_ROOT = "${dotnetSDK}/share/dotnet";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    PATH = "${dotnetSDK}/bin:$HOME/.dotnet/tools:$HOME/.bin:$PATH";
    DOTNET_NOLOGO = "true";
    DOTNET_ADD_GLOBAL_TOOLS_TO_PATH = "true";
    DOTNET_HOST_PATH = "${dotnetSDK}/bin/dotnet";
  };
  shellPlugins = {
    zsh = [ "dotnet" ];
    fish = [];  # TODO: Add fish dotnet completions if available
    bash = [];  # TODO: Add bash dotnet completions if available
  };
  shellInitExtra = {
    zsh = "";
    fish = "";
    bash = "";
  };
  permittedInsecurePackages = [
    "dotnet-sdk-6.0.136"
    "dotnet-sdk-7.0.317"
    "dotnetCorePackages.sdk_7_0_3xx"
  ];
}
