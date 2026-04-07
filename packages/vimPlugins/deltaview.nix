# packages/vimPlugins/deltaview.nix
# Inline diff viewer using delta (git-delta)
{pkgs}:
  pkgs.vimUtils.buildVimPlugin {
    pname = "deltaview-nvim";
    version = "dbb617444d38baeb91922ca03836d928d395f493";
    src = pkgs.fetchFromGitHub {
      owner = "kokusenz";
      repo = "deltaview.nvim";
      rev = "dbb617444d38baeb91922ca03836d928d395f493";
      hash = "sha256-csCQhCwL6wKYV4eaSyjl/ZbGkMKKq64tLnRFDofTgLg=";
    };
  }
