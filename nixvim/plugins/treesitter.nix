# homepage: https://github.com/nvim-treesitter/nvim-treesitter
# nixvim doc: https://nix-community.github.io/nixvim/plugins/treesitter/index.html
{ lib, pkgs, ... }:

{
  opts = {
    # nvim-treesitter master was archived (April 2026). The legacy highlight
    # and indent modules crash on Nvim 0.12's stricter injection semantics.
    # Keep the plugin for its grammars + queries + incremental_selection;
    # use the Nvim builtin highlighter (see extraConfigLuaPost) instead.
    enable = true;
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      bash
      json
      lua
      make
      markdown
      nix
      regex
      toml
      vim
      vimdoc
      xml
      yaml
      typescript
      sql
      rust
      python
      nu
      jsdoc
      javascript
      http
      html
      dockerfile
      c-sharp
      hyprlang
    ];
    settings = {
      highlight = {
        enable = false;
      };
      incremental_selection = {
        enable = true;
        keymaps = {
          init_selection = false;
          node_decremental = "grm";
          node_incremental = "grn";
          scope_incremental = "grc";
        };
      };
      indent = { enable = false; };
    };
  };

  rootOpts = {
    extraConfigLuaPost = ''
      -- Shim nvim-treesitter's custom query predicates/directives for Nvim
      -- 0.12. On 0.12 `match[id]` is a TSNode[]; the archived master-branch
      -- handlers treat it as a single TSNode and crash in `get_node_text`.
      -- plugin/* files load AFTER init.lua, so schedule / BufReadPre /
      -- VimEnter ensure our overrides stick.
      local function install_query_shims()
        local tsq = require('vim.treesitter.query')
        local opts = { force = true }
        local function first_node(match, id)
          local v = match[id]
          if type(v) == 'table' then return v[1] end
          return v
        end
        tsq.add_predicate('nth?', function(match, _p, _b, pred)
          local node = first_node(match, pred[2])
          local n = tonumber(pred[3])
          if node and node:parent() and node:parent():named_child_count() > n then
            return node:parent():named_child(n) == node
          end
          return false
        end, opts)
        tsq.add_predicate('is?', function(match, _p, bufnr, pred)
          local node = first_node(match, pred[2])
          if not node then return true end
          local ok_l, locals = pcall(require, 'nvim-treesitter.locals')
          if not ok_l then return true end
          local _, _, kind = locals.find_definition(node, bufnr)
          return vim.tbl_contains({ unpack(pred, 3) }, kind)
        end, opts)
        tsq.add_predicate('kind-eq?', function(match, _p, _b, pred)
          local node = first_node(match, pred[2])
          if not node then return true end
          return vim.tbl_contains({ unpack(pred, 3) }, node:type())
        end, opts)
        local html_mime = {
          importmap = 'json',
          module = 'javascript',
          ['application/ecmascript'] = 'javascript',
          ['text/ecmascript'] = 'javascript',
        }
        tsq.add_directive('set-lang-from-mimetype!', function(match, _p, bufnr, pred, metadata)
          local node = first_node(match, pred[2])
          if not node then return end
          local value = vim.treesitter.get_node_text(node, bufnr)
          local configured = html_mime[value]
          if configured then
            metadata['injection.language'] = configured
          else
            local parts = vim.split(value, '/', {})
            metadata['injection.language'] = parts[#parts]
          end
        end, opts)
        local non_ft_aliases = { ex = 'elixir', pl = 'perl', sh = 'bash', uxn = 'uxntal', ts = 'typescript' }
        tsq.add_directive('set-lang-from-info-string!', function(match, _p, bufnr, pred, metadata)
          local node = first_node(match, pred[2])
          if not node then return end
          local alias = vim.treesitter.get_node_text(node, bufnr):lower()
          local ft = vim.filetype.match({ filename = 'a.' .. alias })
          metadata['injection.language'] = ft or non_ft_aliases[alias] or alias
        end, opts)
        tsq.add_directive('downcase!', function(match, _p, bufnr, pred, metadata)
          local id = pred[2]
          local node = first_node(match, id)
          if not node then return end
          local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or '''
          if not metadata[id] then metadata[id] = {} end
          metadata[id].text = string.lower(text)
        end, opts)
      end
      pcall(install_query_shims)
      vim.schedule(function() pcall(install_query_shims) end)
      vim.api.nvim_create_autocmd({ 'VimEnter', 'BufReadPre' }, {
        once = true,
        callback = function() pcall(install_query_shims) end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        end,
      })
    '';
  };
}
