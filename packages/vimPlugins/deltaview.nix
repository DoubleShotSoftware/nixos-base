# packages/vimPlugins/deltaview.nix
# Inline diff viewer using delta (git-delta)
{pkgs}:
  pkgs.vimUtils.buildVimPlugin {
    pname = "deltaview-nvim";
    version = "887203397d4a2ea764c85419473ff6641088816b";
    src = pkgs.fetchFromGitHub {
      owner = "kokusenz";
      repo = "deltaview.nvim";
      rev = "887203397d4a2ea764c85419473ff6641088816b";
      hash = "sha256-wMPvxIvQB2hzfGVjjM+pQSCr9Kz2/Ve6SIjH7ygDLL8=";
    };
  }
