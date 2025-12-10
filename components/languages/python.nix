# Python language configuration function
{ pkgs, username }:
{
  packages = with pkgs; [
    python311Full
    python311Packages.pip
    black
    pipenv
    # Note: pyenv removed from default packages to prevent PATH shadowing
    # If you need pyenv for managing multiple Python versions, install it separately
    # and be aware it will prepend ~/.pyenv/shims to PATH
  ];
  sessionVariables = {
    PYTHONDONTWRITEBYTECODE = "1";
  };
  shellPlugins = {
    zsh = [ "python" "pylint" "poetry" ];
    fish = [];  # TODO: Add fish python plugins
    bash = [];  # TODO: Add bash python completions
  };
  shellInitExtra = {
    zsh = "";
    fish = "";
    bash = "";
  };
  permittedInsecurePackages = [];
}
