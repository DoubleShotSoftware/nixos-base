# packages/vimPlugins/git-worktree.nix
# Git worktree management (polarmutex fork)
{pkgs}:
  pkgs.vimUtils.buildVimPlugin {
    pname = "git-worktree-nvim";
    version = "3ad8c17a3d178ac19be925284389c14114638ebb";
    src = pkgs.fetchFromGitHub {
      owner = "polarmutex";
      repo = "git-worktree.nvim";
      rev = "3ad8c17a3d178ac19be925284389c14114638ebb";
      hash = "sha256-fnqJqQTNei+8Gk4vZ2hjRj8iHBXTZT15xp9FvhGB+BQ=";
    };
    # Disable require check - plugin requires plenary at runtime
    doCheck = false;
  }
