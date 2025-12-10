# nixcats/languages/default.nix
# Language-specific editor configurations for nixCats
# NOTE: These are standalone - they don't import from components/languages
# to avoid overlay dependency issues
{ }:
let
  # Available language extensions (editor-specific configs)
  availableLanguages = {
    nix = ./nix.nix;
    dotnet = ./dotnet.nix;
    rust = ./rust.nix;
    python = ./python.nix;
    typescript = ./typescript.nix;
    json = ./json.nix;
    sql = ./sql.nix;
    markdown = ./markdown.nix;
    terraform = ./terraform.nix;
    aws = ./aws.nix;
  };

  # Get editor config for a language
  getEditorConfig = { pkgs, stablePkgs, lang }:
    let
      editorPath = availableLanguages.${lang} or null;
    in
    if editorPath != null then
      import editorPath { inherit pkgs stablePkgs; }
    else
      {
        lspsAndRuntimeDeps = [ ];
        startupPlugins = [ ];
        optionalPlugins = [ ];
        environmentVariables = { };
        extra = { };
      };

  # Merge multiple configs into category format
  mergeConfigs = configs:
    builtins.foldl' (acc: cfg: {
      lspsAndRuntimeDeps = acc.lspsAndRuntimeDeps // (cfg.lspsAndRuntimeDeps or { });
      startupPlugins = acc.startupPlugins // (cfg.startupPlugins or { });
      optionalPlugins = acc.optionalPlugins // (cfg.optionalPlugins or { });
      environmentVariables = acc.environmentVariables // (cfg.environmentVariables or { });
      extra = acc.extra // (cfg.extra or { });
    }) {
      lspsAndRuntimeDeps = { };
      startupPlugins = { };
      optionalPlugins = { };
      environmentVariables = { };
      extra = { };
    } configs;

in {
  # Get all language configs for the given language list
  getLanguageConfigs = { pkgs, stablePkgs, languages }:
    let
      configs = map (lang:
        let
          editorConfig = getEditorConfig { inherit pkgs stablePkgs lang; };
          categoryKey = "languages.${lang}";
        in {
          lspsAndRuntimeDeps.${categoryKey} = editorConfig.lspsAndRuntimeDeps or [ ];
          startupPlugins.${categoryKey} = editorConfig.startupPlugins or [ ];
          optionalPlugins.${categoryKey} = editorConfig.optionalPlugins or [ ];
          environmentVariables.${categoryKey} = editorConfig.environmentVariables or { };
          extra = editorConfig.extra or { };
        }
      ) languages;
    in
    mergeConfigs configs;

  # Export available languages for reference
  inherit availableLanguages;
}
