{ pkgs, ... }:
let
  version = "8dc729a651ae980088246caf651e5ff24e21077a";
  roslyn-language-server = pkgs.vimUtils.buildVimPlugin {
    inherit version;
    name = "roslyn.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "seblyng";
      repo = "roslyn.nvim";
      rev = version;
      hash = "sha256-jrWzIoaorwQk8phqxAM5zoio4reM1e+qjXd/4Syhp24=";
    };
  };
    dotnetSDK = (with pkgs.unstable.dotnetCorePackages;
    combinePackages [
      dotnet_8.sdk
      dotnet_9.sdk
      # dotnet_10.sdk
    ]);
in {
  extraPlugins = [ roslyn-language-server ];
  extraPackages = [ pkgs.unstable.roslyn-ls ];
  extraConfigLuaPost = # lua
    ''
      local roslynDLLPath = "${pkgs.unstable.roslyn-ls}/lib/roslyn-ls/Microsoft.CodeAnalysis.LanguageServer.dll"
      local roslynDotnetPath = "${dotnetSDK}/bin/dotnet"
      ${builtins.readFile ../lua/roslyn-language-server.lua}
    '';
  keymaps = [ ];
}
