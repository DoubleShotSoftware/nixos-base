{ pkgs, dotnetSDK, customVimPlugins, ... }:
{
  extraPlugins = [ customVimPlugins.roslyn-nvim ];
  extraPackages = [ pkgs.stable.roslyn-ls ];
  extraConfigLuaPost = # lua
    ''
      local roslynDLLPath = "${pkgs.stable.roslyn-ls}/lib/roslyn-ls/Microsoft.CodeAnalysis.LanguageServer.dll"
      local roslynDotnetPath = "${dotnetSDK}/bin/dotnet"
      ${builtins.readFile ../lua/roslyn-language-server.lua}
    '';
  keymaps = [ ];
}
