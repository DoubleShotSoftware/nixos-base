{ config, lib, pkgs, inputs, desktop, ... }:
with lib;
with builtins;
let
  marketPlaceExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "tokyo-night";
      publisher = "enkia";
      version = "1.0.6";
      sha256 = "VWdUAU6SC7/dNDIOJmSGuIeffbwmcfeGhuSDmUE7Dig=";
    }
    {
      name = "remote-ssh-edit";
      publisher = "ms-vscode-remote";
      version = "0.86.0";
      sha256 = "JsbaoIekUo2nKCu+fNbGlh5d1Tt/QJGUuXUGP04TsDI=";
    }
    {
      name = "vscode-remote-extensionpack";
      publisher = "ms-vscode-remote";
      version = "0.24.0";
      sha256 = "6v4JWpyMxqTDIjEOL3w25bdTN+3VPFH7HdaSbgIlCmo=";
    }
    {
      name = "remote-explorer";
      publisher = "ms-vscode";
      version = "0.5.2023110609";
      sha256 = "V47Kl621Ov38ReCdzOxDpmagDENNuWK7Z2TGMU8eHSs=";
    }
    {
      name = "remote-server";
      publisher = "ms-vscode";
      version = "1.6.2023110809";
      sha256 = "y9I3cziKvSXEkkWgdo4oAkV76rW6Wh6BiYwbFGxs8zs=";
    }
    {
      name = "vscode-neovim";
      publisher = "asvetliakov";
      version = "1.1.2";
      sha256 = "JIHHwlYLPmzCGg2zMkCj5ZduEOArIHFxVXlcgWzlBHU=";
    }
  ];
  mkUserVSCodeConfig = user: {
    programs = {
      zsh = { oh-my-zsh = { plugins = [ "vscode" ]; }; };
      vscode = {
        enable = true;
        enableExtensionUpdateCheck = true;
        enableUpdateCheck = true;
        package = pkgs.unstable.vscode-fhs;
        # userSettings = {
        #   "breadcrumbs.filePath" = "on";
        #   "[nix]"."editor.tabSize" = 2;
        #   "workbench.iconTheme" = "material-icon-theme";
        #   "workbench.colorTheme" = "Tokyo Night";
        #   "editor.fontFamily" = "Victor Mono";
        #   "extensions.experimental.affinity" = {
        #     "asvetliakov.vscode-neovim" = 1;
        #   };
        #   "vscode-neovim.neovimInitVimPaths.linux" =
        #     "/etc/profiles/${user}/sobrien/bin/nvim";
        #   "files.autoSave" = "onFocusChange";
        #   "editor.bracketPairColorization.independentColorPoolPerBracketType" =
        #     true;
        #   "editor.codeLens" = false;
        #   "editor.fontLigatures" = "'ss01'";
        # };
        extensions = with pkgs.vscode-extensions;
          [
            waderyan.gitblame
            eamodio.gitlens
            ms-azuretools.vscode-docker
            donjayamanne.githistory
            oderwat.indent-rainbow
            shd101wyy.markdown-preview-enhanced
            ms-vscode-remote.remote-ssh
            redhat.vscode-yaml
            editorconfig.editorconfig
            christian-kohler.path-intellisense
          ];# ++ marketPlaceExtensions;

      };
    };
  };
  vsCodeConfigs = mapAttrs (user: config:
    (trace "Enabling vscode for user: ${user}" mkUserVSCodeConfig user))
    (filterAttrs
      (user: userConfig: (userConfig.userType != "system" && userConfig.vscode))
      config.personalConfig.users);
in { config = { home-manager.users = vsCodeConfigs; }; }
