# Language configuration shared logic
{ config, lib, pkgs, ... }:
with lib;
let
  # Get user configs - handle both NixOS and home-manager contexts
  personalConfig = config.personalConfig or config._module.args.personalConfig or {};
  users = personalConfig.users or {};
  
  # Available language modules (function name -> filename mapping)
  availableLanguages = {
    json = ./json.nix;
    dotnet = ./dotnet.nix;
    python = ./python.nix;
    sql = ./sql.nix;
    typescript = ./typescript.nix;
  };
  
  # Function to get language config for a specific language
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
      configs = map (lang: 
        let cfg = getLanguageConfig lang;
        in if cfg == null 
           then trace "Warning: Language '${lang}' not found in availableLanguages" null
           else cfg
      ) enabledLanguages;
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
    
  # For NixOS: get all users with languages
  usersWithLanguages = filterAttrs (name: cfg: (cfg.languages or []) != []) users;
  
in {
  # NixOS configuration - sets home-manager.users for all users
  nixosConfig = mkIf (usersWithLanguages != {}) {
    # System-level permitted insecure packages
    nixpkgs.config.permittedInsecurePackages = mkMerge (
      mapAttrsToList (user: userConfig:
        (getUserLanguageConfigs userConfig).permittedInsecurePackages
      ) usersWithLanguages
    );
    
    # Per-user home-manager configuration
    home-manager.users = mapAttrs (user: userConfig:
      let 
        cfg = getUserLanguageConfigs userConfig;
        userShell = userConfig.shell or "bash";
      in mkMerge [
        {
          home.packages = cfg.packages;
          home.sessionVariables = cfg.sessionVariables;
        }
        # Shell-specific configuration
        (mkIf (userShell == "zsh") {
          programs.zsh.oh-my-zsh.plugins = mkIf (cfg.shellPlugins.zsh != []) cfg.shellPlugins.zsh;
          programs.zsh.initExtra = mkIf (cfg.shellInitExtra.zsh != "") cfg.shellInitExtra.zsh;
        })
        (mkIf (userShell == "fish") {
          # TODO: Add fish plugin configuration when fish plugin system is set up
          programs.fish.interactiveShellInit = cfg.shellInitExtra.fish;
        })
        (mkIf (userShell == "bash") {
          programs.bash.initExtra = cfg.shellInitExtra.bash;
        })
      ]
    ) usersWithLanguages;
  };
  
  # Home-manager configuration - sets home.* for current user
  homeManagerConfig = 
    let
      userList = attrNames users;
      userCount = length userList;
    in
      if userCount == 1 then
        let
          username = head userList;
          userConfig = users.${username};
          cfg = getUserLanguageConfigs userConfig;
          userShell = userConfig.shell or "bash";
        in mkMerge [
          {
            home.packages = cfg.packages;
            home.sessionVariables = cfg.sessionVariables;
          }
          # Shell-specific configuration
          (mkIf (userShell == "zsh") {
            programs.zsh.oh-my-zsh.plugins = mkIf (cfg.shellPlugins.zsh != []) cfg.shellPlugins.zsh;
            programs.zsh.initExtra = mkIf (cfg.shellInitExtra.zsh != "") cfg.shellInitExtra.zsh;
          })
          (mkIf (userShell == "fish") {
            # TODO: Add fish plugin configuration when fish plugin system is set up
            programs.fish.interactiveShellInit = cfg.shellInitExtra.fish;
          })
          (mkIf (userShell == "bash") {
            programs.bash.initExtra = cfg.shellInitExtra.bash;
          })
        ]
      else if userCount == 0 then
        throw "Home-manager language configuration requires exactly one user in personalConfig.users, but found none"
      else
        throw "Home-manager language configuration requires exactly one user in personalConfig.users, but found ${toString userCount} users: ${concatStringsSep ", " userList}";
}