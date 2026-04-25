-- nixcats/lua/plugins/treesitter.lua
-- Treesitter configuration.
--
-- nvim-treesitter's master branch was archived (April 2026) and its legacy
-- `highlight` module is incompatible with Nvim 0.12's stricter injection
-- query semantics (causes `attempt to call method 'range' (a nil value)` on
-- every re-parse). We use the Nvim 0.12 builtin highlighter directly and
-- keep the companion plugin only for textobjects.

-- Shim nvim-treesitter's custom query predicates/directives for Nvim 0.12.
-- On 0.12 `match[id]` is a TSNode[] list (quantified captures); the archived
-- master-branch nvim-treesitter registers handlers that treat it as a single
-- TSNode and crash in `get_node_text`. Re-register AFTER all plugin/* files
-- have loaded (VimEnter) so our versions take over.
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

  local html_script_type_languages = {
    importmap = 'json',
    module = 'javascript',
    ['application/ecmascript'] = 'javascript',
    ['text/ecmascript'] = 'javascript',
  }
  tsq.add_directive('set-lang-from-mimetype!', function(match, _p, bufnr, pred, metadata)
    local node = first_node(match, pred[2])
    if not node then return end
    local value = vim.treesitter.get_node_text(node, bufnr)
    local configured = html_script_type_languages[value]
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
    local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ''
    if not metadata[id] then metadata[id] = {} end
    metadata[id].text = string.lower(text)
  end, opts)
end

-- In Nvim, plugin/* files under `pack/*/start/*/plugin/` are sourced AFTER
-- init.lua. So registering from init.lua is too early — nvim-treesitter's
-- original (broken) handlers get written on top of ours. Re-register at
-- several later points so we always win:
--   - vim.schedule: runs on the first event-loop tick (typically after all
--     plugins have loaded but before interactive mode)
--   - BufReadPre (once): before any file is actually read/parsed
--   - VimEnter (once): after startup completes
pcall(install_query_shims)
vim.schedule(function() pcall(install_query_shims) end)
vim.api.nvim_create_autocmd({ 'VimEnter', 'BufReadPre' }, {
  once = true,
  callback = function() pcall(install_query_shims) end,
})

local has_configs, configs = pcall(require, 'nvim-treesitter.configs')
if has_configs then
  configs.setup({
    auto_install = false,
    highlight = { enable = false },
    indent = { enable = false },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<C-space>',
        node_incremental = '<C-space>',
        scope_incremental = false,
        node_decremental = '<bs>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
        goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
        goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
        goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
      },
      swap = {
        enable = true,
        swap_next = { ['<leader>a'] = '@parameter.inner' },
        swap_previous = { ['<leader>A'] = '@parameter.inner' },
      },
    },
  })
end

vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})

local has_ctx, ctx = pcall(require, 'treesitter-context')
if has_ctx then
  ctx.setup({ enable = true, max_lines = 3 })
end
