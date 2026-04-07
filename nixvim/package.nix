# Function to build nixvim packages
{
  nixpkgs,          # stable nixpkgs
  nixpkgs-unstable,
  nixvim,
  system,
  dotnetSDK,
  customVimPlugins,  # Custom vim plugins from packages/vimPlugins
}:
let
  # Use unstable as base for nixvim
  pkgs = import nixpkgs-unstable {
    inherit system;
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ ];
    };
    overlays = [
      (_final: prev: {
        # Since pkgs is already from unstable, unstable is just prev
        unstable = prev;

        # Add stable overlay for packages that need stability (like roslyn-ls)
        stable = import nixpkgs {
          inherit (prev) system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [ ];
          };
        };

        # Override vimPlugins for nixvim 25.11 compatibility:
        # - nvim-treesitter from stable (unstable removed nvim-treesitter.configs module)
        # - nvim-treesitter-textobjects: disable require check (needs nvim-treesitter loaded first)
        vimPlugins = prev.vimPlugins // {
          inherit (_final.stable.vimPlugins) nvim-treesitter;
          nvim-treesitter-textobjects = prev.vimPlugins.nvim-treesitter-textobjects.overrideAttrs {
            doCheck = false;
          };
        };
      })
      # Neovim overlay for unstable
      (_final: prev: {
        neovim = prev.neovim.overrideAttrs (old: {
          meta = old.meta // {
            license = with nixpkgs.lib.licenses; [
              asl20
              vim
            ];
            maintainers = with nixpkgs.lib.maintainers; [
              manveru
              rvolosatovs
            ];
            platforms = nixpkgs.lib.platforms.unix;
          };
        });
        neovim-unwrapped = prev.neovim-unwrapped.overrideAttrs (old: {
          meta = old.meta // {
            license = with nixpkgs.lib.licenses; [
              asl20
              vim
            ];
            maintainers = with nixpkgs.lib.maintainers; [
              manveru
              rvolosatovs
            ];
            platforms = nixpkgs.lib.platforms.unix;
          };
        });
      })
    ];
  };

  mkNixvim =
    specialArgs:
    nixvim.legacyPackages.${system}.makeNixvimWithModule {
      inherit pkgs;
      module = ./.;
      extraSpecialArgs = specialArgs // {
        inherit pkgs dotnetSDK customVimPlugins;
        icons = import ./utils/_icons.nix;
      };
    };
in
{
  default = mkNixvim { };
  lite = mkNixvim { withLSP = false; };
}
