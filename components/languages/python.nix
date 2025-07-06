# Python language configuration function
{ pkgs }:
{
  packages = with pkgs; [
    python311Full
    python311Packages.pip
    black
    pipenv
  ];
  sessionVariables = {
    PYTHONDONTWRITEBYTECODE = "1";
  };
  shellPlugins = {
    zsh = [ "python" "pylint" "pyenv" "poetry" ];
    fish = [];  # TODO: Add fish python plugins
    bash = [];  # TODO: Add bash python completions
  };
  shellInitExtra = {
    zsh = "";
    fish = "pyenv init - | source 2>/dev/null || true";
    bash = "eval \"$(pyenv init - 2>/dev/null)\" || true";
  };
  permittedInsecurePackages = [];
}