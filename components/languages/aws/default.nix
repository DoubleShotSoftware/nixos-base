{ config, options, pkgs, ... }: {
  home.packages = with pkgs; [ awscli2 ];
  programs.zsh = { oh-my-zsh = { plugins = [ "aws" ]; }; };

}
