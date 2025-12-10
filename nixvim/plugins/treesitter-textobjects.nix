# https://nix-community.github.io/nixvim/plugins/treesitter-textobjects/index.html
{ config, pkgs, ... }: {
  opts = {
    enable = true;

    # Jump across text objects
    move = {
      enable = true;
      setJumps = true;

      gotoNextStart = {
        "]k" = {
          query = "@block.outer";
          desc = "Next block start";
        };
        "]f" = {
          query = "@function.outer";
          desc = "Next function start";
        };
        "]a" = {
          query = "@parameter.inner";
          desc = "Next argument start";
        };
      };

      gotoNextEnd = {
        "]K" = {
          query = "@block.outer";
          desc = "Next block end";
        };
        "]F" = {
          query = "@function.outer";
          desc = "Next function end";
        };
        "]A" = {
          query = "@parameter.inner";
          desc = "Next argument end";
        };
      };

      gotoPreviousStart = {
        "[k" = {
          query = "@block.outer";
          desc = "Previous block start";
        };
        "[f" = {
          query = "@function.outer";
          desc = "Previous function start";
        };
        "[a" = {
          query = "@parameter.inner";
          desc = "Previous argument start";
        };
      };

      gotoPreviousEnd = {
        "[K" = {
          query = "@block.outer";
          desc = "Previous block end";
        };
        "[F" = {
          query = "@function.outer";
          desc = "Previous function end";
        };
        "[A" = {
          query = "@parameter.inner";
          desc = "Previous argument end";
        };
      };
    };

    # Select text objects
    select = {
      enable = true;

      # Automatically jump to next textobjects, ie. if a keymap is pressed
      # while the cursor is not under a textobject, the next relevant
      # textobject will be used as "source", similar to the default nvim
      # behavior
      lookahead = true;

      keymaps = {
        ak = {
          query = "@block.outer";
          desc = "around block";
        };
        ik = {
          query = "@block.inner";
          desc = "inside block";
        };
        ac = {
          query = "@class.outer";
          desc = "around class";
        };
        ic = {
          query = "@class.inner";
          desc = "inside class";
        };
        "a?" = {
          query = "@conditional.outer";
          desc = "around conditional";
        };
        "i?" = {
          query = "@conditional.inner";
          desc = "inside conditional";
        };
        af = {
          query = "@function.outer";
          desc = "around function";
        };
        "if" = {
          query = "@function.inner";
          desc = "inside function";
        };
        ao = {
          query = "@loop.outer";
          desc = "around loop";
        };
        io = {
          query = "@loop.inner";
          desc = "inside loop";
        };
        aa = {
          query = "@parameter.outer";
          desc = "around argument";
        };
        ia = {
          query = "@parameter.inner";
          desc = "inside argument";
        };
      };
    };

    # Swap nodes with next/previous one
    swap = {
      enable = true;

      swapNext = {
        ">K" = {
          query = "@block.outer";
          desc = "Swap next block";
        };
        ">F" = {
          query = "@function.outer";
          desc = "Swap next function";
        };
        ">A" = {
          query = "@parameter.inner";
          desc = "Swap next argument";
        };
      };

      swapPrevious = {
        "<K" = {
          query = "@block.outer";
          desc = "Swap previous block";
        };
        "<F" = {
          query = "@function.outer";
          desc = "Swap previous function";
        };
        "<A" = {
          query = "@parameter.inner";
          desc = "Swap previous argument";
        };
      };
    };
  };
}
