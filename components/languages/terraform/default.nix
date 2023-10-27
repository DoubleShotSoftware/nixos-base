{ config, options, pkgs, ... }:

{
  home.packages = with pkgs; [ terraform terraform-ls terraform-docs ];
  programs.neovim = {
    extraPackages = [ pkgs.terraform-ls ];
    plugins = with pkgs.vimPlugins; [
      {
        plugin = vim-terraform;
        type = "lua";
        config = builtins.readFile (./config_terraform.lua);
      }
      vim-terraform-completion
    ];
  };
}

