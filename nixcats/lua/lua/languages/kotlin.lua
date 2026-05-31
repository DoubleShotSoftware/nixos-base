local nixCats = require('nixCats')

if not nixCats.cats["languages.kotlin"] then
  return
end

-- Disable easy-kotlin's auto-setup: its plugin/easy-kotlin.lua calls
-- setup() with no args during :packloadall (after init.lua), which would
-- clobber our explicit configuration below.
vim.g.easy_kotlin_disable_auto_setup = true

vim.filetype.add({
  extension = {
    kt = 'kotlin',
    kts = 'kotlin',
  },
  pattern = {
    ['.*/build%.gradle%.kts'] = 'kotlin',
    ['.*/settings%.gradle%.kts'] = 'kotlin',
  },
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('KotlinLanguageSetup', { clear = true }),
  pattern = 'kotlin',
  callback = function(ev)
    local opts = {
      shiftwidth = 4,
      softtabstop = 4,
      tabstop = 4,
      expandtab = true,
    }

    for key, value in pairs(opts) do
      vim.bo[ev.buf][key] = value
    end
  end,
})

-- =============================================================================
-- easy-kotlin setup (owns LSP + build/test runner + project introspection)
-- =============================================================================

-- Per-root system-path keeps kotlin-lsp's workspace state isolated per project,
-- and pipes stderr to a stable file for post-mortem debugging.
local kotlin_lsp = nixCats.extra.kotlinLspBinary or 'kotlin-lsp'
local kotlin_state_dir = vim.fn.stdpath('state') .. '/kotlin-lsp'
local kotlin_err_log = kotlin_state_dir .. '.err'
-- kotlin-lsp's analyzer cache (RocksDB-backed) lives under
-- $XDG_CONFIG_HOME/JetBrains/analyzer/workspaces/<project-sha>/. With the
-- default XDG path, that's ~/.config/JetBrains/analyzer — exactly where the
-- IntelliJ desktop app keeps *its* analyzer cache. Same project sha, same
-- RocksDB LOCK, so opening one kicks the other into "stuck initializing".
-- Give the LSP child its own XDG root so it carves out a parallel
-- ~/.local/state/nvim/kotlin-lsp/xdg/JetBrains/analyzer hierarchy and leaves
-- IntelliJ's alone.
local kotlin_xdg_config_home = kotlin_state_dir .. '/xdg-config'
vim.fn.mkdir(kotlin_xdg_config_home, 'p')

local function kotlin_cmd(dispatchers, config)
  local root = (config and config.root_dir) or vim.loop.cwd() or vim.fn.getcwd()
  local system_path = kotlin_state_dir .. '/' .. vim.fn.sha256(root)
  vim.fn.mkdir(system_path, 'p')

  -- vim.lsp doesn't merge config.cmd_env into the spawned process when `cmd`
  -- is a function (only when it's an argv list). Inline KEY=VAL prefixes here
  -- so values from easy-kotlin.setup({ lsp.config.cmd_env = {...} }) reach
  -- the kotlin-lsp child.
  local env_prefix = ''
  if config and config.cmd_env then
    for k, v in pairs(config.cmd_env) do
      env_prefix = env_prefix .. string.format('%s=%s ', k, vim.fn.shellescape(tostring(v)))
    end
  end

  local shell_cmd = string.format(
    '%sexec %s --stdio --system-path %s 2>> %s',
    env_prefix,
    vim.fn.shellescape(kotlin_lsp),
    vim.fn.shellescape(system_path),
    vim.fn.shellescape(kotlin_err_log)
  )

  return vim.lsp.rpc.start({ 'sh', '-c', shell_cmd }, dispatchers, {
    cwd = root,
  })
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_blink, blink = pcall(require, 'blink.cmp')
if ok_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- kotlin-lsp returns completion items in JetBrains' two-phase apply
-- format: textEdit.newText is empty + a zero-width range, with all the
-- real insertion deferred behind a `command = "jetbrains.kotlin.completion.apply"`
-- on the item. vscode's language client speaks this dialect natively;
-- blink does not — blink's default_implementation runs against the
-- empty textEdit, falls back to its own prefix heuristic using `label`,
-- and lands the cursor one position short of where the server's
-- subsequent workspace/applyEdit actually places the insertion. Result:
-- `Strin|g` instead of `String|`, `easykotlin|.` instead of `easykotlin|`.
--
-- Strip the `command` resolve property and the `insertReplaceSupport`
-- flag so kotlin-lsp falls back to its plain-LSP path: `newText` carries
-- the real insertion suffix, range covers the typed prefix, no command
-- to resolve. blink's default flow handles that shape correctly.
--
-- snippetSupport was already off — leaving it that way is unrelated but
-- not worth toggling back on; nothing in easy-kotlin needs snippet
-- placeholders.
local completionItem = capabilities.textDocument.completion.completionItem
completionItem.snippetSupport = false
completionItem.insertReplaceSupport = false
if completionItem.resolveSupport and completionItem.resolveSupport.properties then
  completionItem.resolveSupport.properties = vim.tbl_filter(
    function(p) return p ~= "command" end,
    completionItem.resolveSupport.properties
  )
end

-- Symbol-resolution JDK for kotlin-lsp: prefer the user's $JAVA_HOME if set
-- (lets project-specific shells override), otherwise pin to the nixpkgs
-- jdk25_headless we wire through `kotlinSymbolSdkHome`. The bundled JBR
-- works for *running* the LSP but ships no `lib/src.zip`, so JDK method
-- docstrings come back blank — distinct from the Gradle-import JDK below.
local kotlin_default_sdk = vim.env.JAVA_HOME
  and vim.env.JAVA_HOME ~= ''
  and vim.env.JAVA_HOME
  or nixCats.extra.kotlinSymbolSdkHome

-- Pin the sidecar log file under the canonical `~/.local/state/nvim/`
-- directory regardless of the active runtime (nixcats's `stdpath('state')`
-- otherwise lands it under `~/.local/state/nixcats/`, splitting the log
-- across two locations depending on how nvim was launched). Matches the
-- path the easy-kotlin README documents as the default. slf4j-simple
-- opens this in TRUNCATE mode at every sidecar launch — fresh file each
-- restart — so the parent directory must exist before the sidecar starts.
local kotlin_sidecar_log = vim.fn.expand('~/.local/state/nvim/easy-kotlin.log')
vim.fn.mkdir(vim.fn.fnamemodify(kotlin_sidecar_log, ':h'), 'p')

-- Plugin-side Lua logger, distinct from sidecar.log (which configures
-- the JVM's slf4j-simple). This logger captures Lua-side events:
-- sidecar lifecycle decisions, RPC request/response correlation, autocmd
-- flow, on_exit codes. Append-mode (vs. the sidecar log's TRUNCATE), so
-- it accumulates across nvim sessions. Pinned under the same canonical
-- ~/.local/state/nvim/ dir as the sidecar log so post-mortem debugging
-- doesn't have to chase two parallel state hierarchies.
local kotlin_plugin_log = vim.fn.expand('~/.local/state/nvim/easy-kotlin.plugin.log')
vim.fn.mkdir(vim.fn.fnamemodify(kotlin_plugin_log, ':h'), 'p')

require('easy-kotlin').setup({
  lsp = {
    cmd = kotlin_cmd,
    config = {
      capabilities = capabilities,
      -- Bypass IntelliJ's JavaHomeFinder (which fails on nixpkgs JDK layouts
      -- because `release` lives under lib/openjdk, not at the home root) and
      -- hand kotlin-lsp's gradle importer the bundled JBR directly. The
      -- system property is the documented escape hatch in
      -- GradleToolingApiHelper.findTheMostCompatibleJdk.
      cmd_env = {
        JAVA_TOOL_OPTIONS =
          '-Dcom.jetbrains.ls.imports.gradle.java.home=' .. nixCats.extra.kotlinGradleJdkHome,
        XDG_CONFIG_HOME = kotlin_xdg_config_home,
      },
      -- initializationOptions sent at LSP init.
      -- Mirrors kotlin-vscode/lspClient.ts:294 — only `defaultSdk` and
      -- `buildTools` are consumed by the server itself.
      init_options = {
        defaultSdk = kotlin_default_sdk,
      },
    },
  },
  sidecar = {
    cmd = nixCats.extra.kotlinSidecarBinary,
    -- Sidecar JVM logging via slf4j-simple. Each key here gets passed as
    -- a `-Dorg.slf4j.simpleLogger.<key>=value` system property at sidecar
    -- launch. Restated explicitly (vs. inheriting easy-kotlin's defaults)
    -- so the dial is visible in this config — flip `level` to "trace" /
    -- "info" / "off" without bumping the easy-kotlin flake input, and
    -- the file path is pinned to a stable `~/.local/state/nvim/` location
    -- regardless of how nvim was launched (matches the easy-kotlin
    -- README's documented default).
    --
    -- TRUNCATEd on each sidecar restart. For append-mode history, set
    -- `file = "System.err"` and rely on sidecar stderr capture under
    -- `log_dir`.
    log = {
      level = "debug", -- "trace" | "debug" | "info" | "warn" | "error" | "off"
      file = kotlin_sidecar_log,
    },
  },
  -- easy-kotlin owns the `<leader>la` workaround for the nvim-0.12
  -- pull-diagnostic / kotlin-lsp identifier mismatch. Buffer-local on
  -- LspAttach for kotlin_lsp only; other LSPs keep the stock keymap from
  -- nixcats/lua/lua/plugins/lsp.lua:62.
  keymaps = {
    code_action = '<leader>la',
  },
  -- Plugin-side logger (Lua). Restated explicitly (vs. inheriting easy-kotlin's
  -- defaults) so the dial is visible here — flip `enabled = false` for a hard
  -- zero-cost short circuit, or bump `level` to "trace"/"warn"/etc. without
  -- bumping the easy-kotlin flake input.
  log = {
    enabled = true,
    level = "debug", -- "trace" | "debug" | "info" | "warn" | "error"
    file = kotlin_plugin_log,
  },
  -- kotlin-lsp's completion-accept flow ends with a `window/showDocument`
  -- request whose `selection.start` is END of the inserted text. nvim's
  -- stock handler honors that via `nvim_win_set_cursor`, but in NORMAL
  -- mode that target is silently clamped one position short of line-end —
  -- producing `x.siz|e` instead of `x.size|`. easy-kotlin's
  -- `completion.lua` works around it via `setlocal virtualedit=onemore`
  -- per kotlin buffer. Restated here (default is already true) so the
  -- dial is visible — set `false` to disable and live with the
  -- off-by-one cursor on accept.
  completion = {
    one_more_hack = true,
  },
  -- Tree-sitter-driven gutter markers (override / suspend / operator /
  -- infix / inline / tailrec / super / companion). Defaults are good;
  -- override `keywords` here to swap Nerd Font glyphs, change priority
  -- ordering, or drop entries — see lua/easy-kotlin/init.lua's defaults
  -- block for the canonical map. `signcolumn_width` reserves N sign
  -- columns per kotlin buffer; bump higher when running with many
  -- concurrent sign sources (diagnostics + git + markers).
  gutter_marks = {
    enabled = true,
    signcolumn_width = 2,
  },
})

-- =============================================================================
-- Keybindings (mirrors easy-dotnet's <leader>lb* prefix; buffer-local)
-- =============================================================================

local function setup_kotlin_keymaps()
  local opts = { buffer = true }
  vim.keymap.set('n', '<leader>lbb', '<cmd>KotlinBuild<CR>',          vim.tbl_extend('force', opts, { desc = 'Build (gradle build)' }))
  vim.keymap.set('n', '<leader>lbt', '<cmd>KotlinTest<CR>',           vim.tbl_extend('force', opts, { desc = 'Test (gradle test)' }))
  vim.keymap.set('n', '<leader>lbr', '<cmd>KotlinRefreshProject<CR>', vim.tbl_extend('force', opts, { desc = 'Refresh gradle project' }))
  vim.keymap.set('n', '<leader>lbm', '<cmd>KotlinModules<CR>',        vim.tbl_extend('force', opts, { desc = 'Module picker' }))
  vim.keymap.set('n', '<leader>lbs', '<cmd>KotlinStatus<CR>',         vim.tbl_extend('force', opts, { desc = 'Kotlin status' }))
  vim.keymap.set('n', '<leader>lbh', '<cmd>KotlinHealth<CR>',         vim.tbl_extend('force', opts, { desc = 'Kotlin health' }))
  vim.keymap.set('n', '<leader>lbL', '<cmd>KotlinRestartLsp<CR>',     vim.tbl_extend('force', opts, { desc = 'Restart kotlin-lsp' }))
  vim.keymap.set('n', '<leader>lbx', '<cmd>KotlinCancel<CR>',         vim.tbl_extend('force', opts, { desc = 'Cancel running jobs' }))
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('KotlinKeymaps', { clear = true }),
  pattern = 'kotlin',
  callback = setup_kotlin_keymaps,
})
