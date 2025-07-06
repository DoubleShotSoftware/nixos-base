# Function to build nixvim packages
{ nixpkgs
, nixpkgs-unstable
, nixvim
, system
}:
let
  pkgs = import nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ ];
    };
    overlays = [
      (_final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (prev) system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [ ];
          };
          overlays = [
            (unstableFinal: unstablePrev: {
              neovim = unstablePrev.neovim.overrideAttrs (old: {
                meta = old.meta // {
                  license = with nixpkgs.lib.licenses; [ asl20 vim ];
                  maintainers = with nixpkgs.lib.maintainers; [
                    manveru
                    rvolosatovs
                  ];
                  platforms = nixpkgs.lib.platforms.unix;
                };
              });
              neovim-unwrapped = unstablePrev.neovim-unwrapped.overrideAttrs (old: {
                meta = old.meta // {
                  license = with nixpkgs.lib.licenses; [ asl20 vim ];
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
      })
    ];
  };

  mkNixvim = specialArgs:
    nixvim.legacyPackages.${system}.makeNixvimWithModule {
      inherit pkgs;
      module = ./.;
      extraSpecialArgs = specialArgs // {
        inherit pkgs;
        icons = import ./utils/_icons.nix;
      };
    };
in
{
  default = mkNixvim { };
  lite = mkNixvim { withLSP = false; };
}