# Language configuration module that dynamically loads enabled languages
{ config, lib, options, pkgs, ... }:
with lib;
let
  # Check context
  isNixOS = options ? home-manager.users;
  isHomeManager = options ? home.packages;
  
  # Get user configs
  users = config.personalConfig.users;
  
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
  
  # For home-manager: get current user
  currentUser = if isHomeManager then config.home.username or null else null;
  currentUserConfig = if currentUser != null && users ? ${currentUser}
    then getUserLanguageConfigs users.${currentUser}
    else null;
    
in {
  config = mkMerge [
    # NixOS context - configure all users
    (mkIf (isNixOS && usersWithLanguages != {}) {
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
    })
    
    # Home-manager context - configure current user
    (mkIf (isHomeManager && currentUserConfig != null && currentUser != null) (
      let
        userConfig = users.${currentUser};
        userShell = userConfig.shell or "bash";
      in mkMerge [
        {
          home.packages = currentUserConfig.packages;
          home.sessionVariables = currentUserConfig.sessionVariables;
        }
        # Shell-specific configuration
        (mkIf (userShell == "zsh") {
          programs.zsh.oh-my-zsh.plugins = mkIf (currentUserConfig.shellPlugins.zsh != []) currentUserConfig.shellPlugins.zsh;
          programs.zsh.initExtra = mkIf (currentUserConfig.shellInitExtra.zsh != "") currentUserConfig.shellInitExtra.zsh;
        })
        (mkIf (userShell == "fish") {
          # TODO: Add fish plugin configuration when fish plugin system is set up
          programs.fish.interactiveShellInit = currentUserConfig.shellInitExtra.fish;
        })
        (mkIf (userShell == "bash") {
          programs.bash.initExtra = currentUserConfig.shellInitExtra.bash;
        })
      ]
    ))
  ];
}