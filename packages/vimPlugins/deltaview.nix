# packages/vimPlugins/deltaview.nix
# Inline diff viewer; since v0.4.0 delta.lua (treesitter diff highlighting) is
# bundled into deltaview.nvim itself, so the separate delta.lua dependency is gone.
{pkgs}:
  pkgs.vimUtils.buildVimPlugin {
    pname = "deltaview-nvim";
    version = "818c0bd538e2158047f1979a18f70689a83a670e";
    src = pkgs.fetchFromGitHub {
      owner = "kokusenz";
      repo = "deltaview.nvim";
      rev = "818c0bd538e2158047f1979a18f70689a83a670e";
      hash = "sha256-bRYvpiYckkNFJA47Ix9iOO9kY5wOW0euW/MylZihS3M=";
    };
    # The bundled delta.lua runs `git` at module load (plugin/commands.lua), which
    # isn't on PATH in the build env, so the require-check fails at build time.
    doCheck = false;
  }
