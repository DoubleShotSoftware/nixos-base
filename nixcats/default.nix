# nixcats/default.nix - Builder module for nixCats-based Neovim
#
# Usage:
#   nixcatsLib = import ./nixcats { inherit nixpkgs nixpkgs-unstable nixCats; };
#   package = nixcatsLib.mkNixCats {
#     system = "x86_64-linux";
#     pkgs = unstablePkgs;      # Pre-configured pkgs with overlay
#     stablePkgs = stablePkgs;  # Stable pkgs for packages needing stability
#     languages = ["dotnet" "rust"];
#   };
#
{ nixpkgs, nixpkgs-unstable, nixCats }:
let
  # Import language modules
  languageModules = import ./languages { };

in {
  # Main builder function
  mkNixCats = {
    system,
    pkgs,                      # Pre-configured pkgs (with overlay applied)
    stablePkgs,                # Stable pkgs for packages that need stability
    languages ? [ "nix" ],     # List of language names to enable
    theme ? "tokyonight",      # Colorscheme: "tokyonight" or "catppuccin"
    wrapRc ? true,             # true = hermetic, false = dev mode (live reload)
    extraCategories ? { },     # Additional category overrides
    extraPlugins ? [ ],        # Additional plugins to include
    extraPackages ? [ ],       # Additional runtime packages
  }:
  let
    # Alias outer pkgs — the package function args below shadow `pkgs` with
    # nixCats's builder pkgs (derived from stable nixpkgs input), so we need
    # a distinct name to reach the unstable pkgs we were passed.
    unstablePkgs = pkgs;

    # Custom plugins from overlay (using outer pkgs which has the overlay)
    telescopeTabs = pkgs.customVimPlugins.telescope-tabs;
    codediff = pkgs.customVimPlugins.codediff;
    deltaview = pkgs.customVimPlugins.deltaview;
    gitWorktree = pkgs.customVimPlugins.git-worktree;

    # Convert languages list to category enables
    # e.g., ["dotnet" "rust"] -> { "languages.dotnet" = true; "languages.rust" = true; }
    languageCategories = builtins.listToAttrs (
      map (lang: {
        name = "languages.${lang}";
        value = true;
      }) languages
    );

    # Build category definitions from language modules
    # Note: The `pkgs` in packageDef is from nixCats, not our overlay.
    # Use outer-scope variables for overlay-specific packages.
    categoryDefinitions = { pkgs, settings, categories, extra, name, mkNvimPlugin, ... }@packageDef: {
        # General/shared dependencies
        lspsAndRuntimeDeps = {
          general = with pkgs; [
            ripgrep
            fd
            tree-sitter
            fzf
            git
            lazygit
            delta   # Required for deltaview
            nodejs  # Required for copilot
            stylua  # Lua formatter
            lua-language-server  # Lua LSP
          ];
        } // langConfigs.lspsAndRuntimeDeps;

        # Startup plugins (always loaded)
        startupPlugins = {
          general = with pkgs.vimPlugins; [
            plenary-nvim
            nvim-web-devicons
            # Colorschemes
            catppuccin-nvim
            tokyonight-nvim
            # Core UI
            lualine-nvim
            noice-nvim
            nui-nvim
            nvim-notify
            # Core editing
            comment-nvim
            nvim-autopairs
            # Treesitter
            nvim-treesitter.withAllGrammars
            nvim-treesitter-textobjects
            nvim-treesitter-context
            # Folding
            promise-async
            nvim-ufo
            # LSP
            nvim-lspconfig
            fidget-nvim
            lspsaga-nvim
            # Completion
            blink-cmp
            # Telescope
            telescope-nvim
            telescope-fzf-native-nvim
            # Git
            gitsigns-nvim
            diffview-nvim
            lazygit-nvim
            # File explorer
            neo-tree-nvim
            # Which-key
            which-key-nvim
            # Trouble
            trouble-nvim
            # Flash (navigation)
            flash-nvim
            # Indent guides
            indent-blankline-nvim
            # Misc
            todo-comments-nvim
            mini-nvim
            snacks-nvim
            # Tab bar
            tabby-nvim
            # Markdown preview
            render-markdown-nvim
            # Formatting
            conform-nvim
          ] ++ [
            telescopeTabs  # Custom plugin from overlay (outer scope)
            codediff       # VSCode-style diff viewer
            deltaview      # Inline diff viewer using delta
            gitWorktree    # Git worktree management
          ] ++ extraPlugins;
        } // langConfigs.startupPlugins;

        # Optional plugins (loaded on demand)
        optionalPlugins = {
          debug = with pkgs.vimPlugins; [
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
          ];
        } // langConfigs.optionalPlugins;

        # Environment variables
        environmentVariables = {
          general = { };
        } // langConfigs.environmentVariables;

        # Extra wrapper args
        extraWrapperArgs = {
          general = [ ];
        };

        # Shared libraries (for plugins with native deps)
        sharedLibraries = {
          general = [ ];
        };

        # Extra Python packages
        extraPython3Packages = {
          general = _: [ ];
        };

        # Extra Lua packages
        extraLuaPackages = {
          general = [ ];
        };
      };

    # Get language configs (used by both categoryDefinitions and packageDefinitions)
    langConfigs = languageModules.getLanguageConfigs {
      inherit pkgs stablePkgs languages;
    };

    # Package definition
    packageDefinitions = {
      nixcats-ide = { pkgs, mkNvimPlugin, ... }: {
        settings = {
          inherit wrapRc;
          configDirName = "nixcats";
          aliases = [ "e" "nvim" "vim" "vi" ];
          # Use neovim from unstable (0.12) rather than nixCats's default pkgs
          # (which is derived from the stable nixpkgs input = 25.11 = 0.11.x)
          neovim-unwrapped = unstablePkgs.neovim-unwrapped;
          # For wrapRc = false, use this path for lua config
          unwrappedCfgPath = ./lua;
        };
        categories = {
          general = true;
          debug = builtins.elem "debug" (builtins.attrNames extraCategories) || false;
        } // languageCategories // extraCategories;
        extra = {
          # Pass extra data to Lua via nixCats()
          enabledLanguages = languages;
          theme = theme;
        } // langConfigs.extra;
      };
    };

    # Default package name
    defaultPackageName = "nixcats-ide";

  in nixCats.utils.baseBuilder ./lua {
    inherit nixpkgs system;
    extra_pkg_config = {
      allowUnfree = true;
    };
  } categoryDefinitions packageDefinitions defaultPackageName;
}
