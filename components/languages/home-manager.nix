# Home-manager-level language configuration module
# This module expects exactly one user in personalConfig.users
{ config, lib, pkgs, ... }:
with lib;
let
  # Import language configs
  availableLanguages = {
    json = ./json.nix;
    dotnet = ./dotnet.nix;
    python = ./python.nix;
    sql = ./sql.nix;
    typescript = ./typescript.nix;
  };
  
  # Function to get language config
  getLanguageConfig = language:
    if availableLanguages ? ${language}
    then import availableLanguages.${language} { inherit pkgs; }
    else null;
    
  # Function to merge language configs
  mergeLanguageConfigs = configs:
    foldl' (acc: cfg: {
      packages = acc.packages ++ (cfg.packages or []);
      sessionVariables = acc.sessionVariables // (cfg.sessionVariables or {});
      shellPlugins = {
        zsh = acc.shellPlugins.zsh ++ (cfg.shellPlugins.zsh or []);
        fish = acc.shellPlugins.fish ++ (cfg.shellPlugins.fish or []);
        bash = acc.shellPlugins.bash ++ (cfg.shellPlugins.bash or []);
      };
      shellInitExtra = {
        zsh = if (cfg.shellInitExtra.zsh or "") != "" 
              then acc.shellInitExtra.zsh + (if acc.shellInitExtra.zsh != "" then "\n" else "") + cfg.shellInitExtra.zsh
              else acc.shellInitExtra.zsh;
        fish = if (cfg.shellInitExtra.fish or "") != ""
               then acc.shellInitExtra.fish + (if acc.shellInitExtra.fish != "" then "\n" else "") + cfg.shellInitExtra.fish
               else acc.shellInitExtra.fish;
        bash = if (cfg.shellInitExtra.bash or "") != ""
               then acc.shellInitExtra.bash + (if acc.shellInitExtra.bash != "" then "\n" else "") + cfg.shellInitExtra.bash
               else acc.shellInitExtra.bash;
      };
      permittedInsecurePackages = acc.permittedInsecurePackages ++ (cfg.permittedInsecurePackages or []);
    }) {
      packages = [];
      sessionVariables = {};
      shellPlugins = { zsh = []; fish = []; bash = []; };
      shellInitExtra = { zsh = ""; fish = ""; bash = ""; };
      permittedInsecurePackages = [];
    } configs;
    
  # Get configs for enabled languages for a user
  getUserLanguageConfigs = userConfig:
    let
      enabledLanguages = userConfig.languages or [];
      configs = map getLanguageConfig (filter (l: l != null) enabledLanguages);
      validConfigs = filter (cfg: cfg != null) configs;
    in if validConfigs == []
       then { 
         packages = []; 
         sessionVariables = {}; 
         shellPlugins = { zsh = []; fish = []; bash = []; };
         shellInitExtra = { zsh = ""; fish = ""; bash = ""; };
         permittedInsecurePackages = []; 
       }
       else mergeLanguageConfigs validConfigs;
       
  # Access personalConfig in let bindings to avoid infinite recursion
  hasPersonalConfig = config ? personalConfig && config.personalConfig ? users;
  users = if hasPersonalConfig then config.personalConfig.users else {};
  userList = attrNames users;
  userCount = length userList;
  
  # Process the configuration if we have exactly one user
  languageConfig = 
    if userCount == 1 then
      let
        username = head userList;
        userConfig = users.${username};
        cfg = getUserLanguageConfigs userConfig;
        userShell = userConfig.shell or "bash";
      in {
        inherit cfg userShell;
        hasConfig = true;
      }
    else if userCount == 0 then
      throw "Home-manager language configuration requires exactly one user in personalConfig.users, but found none"
    else
      throw "Home-manager language configuration requires exactly one user in personalConfig.users, but found ${toString userCount} users: ${concatStringsSep ", " userList}";
      
in {
  config = mkIf (hasPersonalConfig && languageConfig.hasConfig) (mkMerge [
    {
      home.packages = languageConfig.cfg.packages;
      home.sessionVariables = languageConfig.cfg.sessionVariables;
    }
    # Shell-specific configuration
    (mkIf (languageConfig.userShell == "zsh") {
      programs.zsh.oh-my-zsh.plugins = mkIf (languageConfig.cfg.shellPlugins.zsh != []) languageConfig.cfg.shellPlugins.zsh;
      programs.zsh.initExtra = mkIf (languageConfig.cfg.shellInitExtra.zsh != "") languageConfig.cfg.shellInitExtra.zsh;
    })
    (mkIf (languageConfig.userShell == "fish") {
      programs.fish.interactiveShellInit = mkIf (languageConfig.cfg.shellInitExtra.fish != "") languageConfig.cfg.shellInitExtra.fish;
    })
    (mkIf (languageConfig.userShell == "bash") {
      programs.bash.initExtra = mkIf (languageConfig.cfg.shellInitExtra.bash != "") languageConfig.cfg.shellInitExtra.bash;
    })
  ]);
}