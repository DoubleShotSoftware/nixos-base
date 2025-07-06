{ pkgs, lib, ... }:
let
  makeBlinkAction = luaModule: methods:
    let
      len = lib.length methods;
      initList = lib.take (len - 1) methods; # everything but the last
      lastMethod = lib.elemAt methods (len - 1); # the very last entry
      checks = lib.concatStringsSep "\n    "
        (map (m: "if cmp." + m + "() then return true end") initList);
    in ''
      function()
        local cmp = require("${luaModule}")
        ${checks}
        return cmp.${lastMethod}()
      end
    '';
in {
  opts = {
    enable = true;
    package = pkgs.unstable.vimPlugins.blink-cmp;
    settings = {
      appearance = {
        use_nvim_cmp_as_default = false;
        nerd_font_variant = "normal";
      };
      completion = {
        accept = {
          auto_brackets = {
            enabled = false;
            semantic_token_resolution = { enabled = false; };
          };
        };
        menu = {
          draw = {
            treesitter = [ "lsp" ];
            # Colorful menu integration
            columns = [ [ "kind_icon" ] [ "label" "label_description" ] ];
            components = {
              label = {
                text.__raw = ''
                  function(ctx)
                    return require("colorful-menu").blink_components_text(ctx)
                  end
                '';
                highlight.__raw = ''
                  function(ctx)
                    return require("colorful-menu").blink_components_highlight(ctx)
                  end
                '';
              };
            };
          };
        };
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 200;
        };
        ghost_text = { enabled.__raw = "vim.g.ai_cmp"; };
      };
      sources = {
        compat = { };
        default = [ "lsp" "path" "snippets" ];
        # "spell" "dictionary" 
      };
      cmdline = { enabled = false; };
      fuzzy = { implementation = "prefer_rust_with_warning"; };
      keymap = {
        preset = "super-tab";
        "<C-space>" = [ "show" "show_documentation" "hide_documentation" ];
        # ["<C-e>"] = [ "hide"; "fallback" ];
        #
        # ["<Tab>"] = [
        #   function(cmp)
        #     if cmp.snippet_active() then return cmp.accept()
        #     else return cmp.select_and_accept() end
        #   end;
        #   "snippet_forward";
        #   "fallback"
        # ];
        # ["<S-Tab>"] = [ "snippet_backward"; "fallback" ];
        #
        # ["<Up>"] = [ "select_prev"; "fallback" ];
        # ["<Down>"] = [ "select_next"; "fallback" ];
        # ["<C-p>"] = [ "select_prev"; "fallback_to_mappings" ];
        # ["<C-n>"] = [ "select_next"; "fallback_to_mappings" ];
        #
        # ["<C-b>"] = [ "scroll_documentation_up"; "fallback" ];
        # ["<C-f>"] = [ "scroll_documentation_down"; "fallback" ];
        #
        "<C-k>" = [ "show_signature" "hide_signature" "fallback" ];
        #
      };
      signature = {
        enabled = true;
        trigger = {
          enabled = true;
          # Show the signature help automatically
          # Show the signature help window after typing any of alphanumerics; `-` or `_`
          show_on_keyword = false;
          blocked_trigger_characters = [ ];
          blocked_retrigger_characters = [ ];
          # Show the signature help window after typing a trigger character
          show_on_trigger_character = true;
          # Show the signature help window when entering insert mode
          show_on_insert = false;
          # Show the signature help window when the cursor comes after a trigger character when entering insert mode
          show_on_insert_on_trigger_character = true;
        };
        window = { show_documentation = true; };
      };
    };
  };
  rootOpts = {
    keymaps = [
      #
      # # <C-space>
      # {
      #   key = "<C-space>";
      #   action.__raw = makeBlinkAction "blink.cmp" [
      #     "show"
      #     "show_documentation"
      #     "hide_documentation"
      #   ];
      #   mode = [ "i" "n" ];
      #   options = { silent = true; };
      # }
      #
      # # <C-e>
      # {
      #   key = "<C-e>";
      #   action.__raw = makeBlinkAction "blink.cmp" [ "hide" "fallback" ];
      #   mode = [ "i" "n" ];
      #   options = { silent = true; };
      # }
      #
      # # <Tab> (custom branch + then snippet_forward → fallback)
      # {
      #   key = "<Tab>";
      #   action.__raw = # lua
      #     ''
      #       function()
      #         local cmp = require("blink.cmp")
      #         if cmp.snippet_active() then
      #           return cmp.accept()
      #         else
      #           return cmp.select_and_accept()
      #         end
      #         -- if neither returned truthy, fall back to snippet_forward then fallback
      #         if cmp.snippet_forward() then return true end
      #         return cmp.fallback()
      #       end
      #     '';
      #   mode = [ "i" "n" ];
      #   options = {
      #     silent = true;
      #     expr = true; # so Neovim respects our return value
      #   };
      # }
      #
      # # <S-Tab>
      # {
      #   key = "<S-Tab>";
      #   mode = [ "i" "n" ];
      #   action.__raw =
      #     makeBlinkAction "blink.cmp" [ "snippet_backward" "fallback" ];
      #   options = { silent = true; };
      # }
      #
      # # ↑ / ↓
      # {
      #   key = "<Up>";
      #   action.__raw = makeBlinkAction "blink.cmp" [ "select_prev" "fallback" ];
      #   mode = [ "i" "n" ];
      #   options = { silent = true; };
      # }
      # {
      #   key = "<Down>";
      #   action.__raw = makeBlinkAction "blink.cmp" [ "select_next" "fallback" ];
      #   mode = [ "i" "n" ];
      #   options = { silent = true; };
      # }
      #
      # # <C-p> / <C-n>
      # {
      #   key = "<C-p>";
      #   action.__raw =
      #     makeBlinkAction "blink.cmp" [ "select_prev" "fallback_to_mappings" ];
      #   mode = [ "i" "n" ];
      #   options = { silent = true; };
      # }
      # {
      #   key = "<C-n>";
      #   action.__raw =
      #     makeBlinkAction "blink.cmp" [ "select_next" "fallback_to_mappings" ];
      #   mode = [ "i" "n" ];
      #   options = { silent = true; };
      # }
      #
      # # scroll doc
      # {
      #   key = "<C-b>";
      #   action.__raw =
      #     makeBlinkAction "blink.cmp" [ "scroll_documentation_up" "fallback" ];
      #   mode = [ "i" "n" ];
      #   options = { silent = true; };
      # }
      # {
      #   key = "<C-f>";
      #   action.__raw = makeBlinkAction "blink.cmp" [
      #     "scroll_documentation_down"
      #     "fallback"
      #   ];
      #   mode = [ "i" "n" ];
      #   options = { silent = true; };
      # }
      #
      # # signature toggle
      # {
      #   key = "<C-k>";
      #   action.__raw = makeBlinkAction "blink.cmp" [
      #     "show_signature"
      #     "hide_signature"
      #     "fallback"
      #   ];
      #   mode = [ "i" "n" ];
      #   options = {
      #     silent = true;
      #     expr = true;
      #   };
      # }
    ];
  };
}
