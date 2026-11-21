-- nixcats/lua/lua/languages/dotnet/dotnet.lua
-- .NET development setup
-- easy-dotnet.nvim handles LSP (built-in roslyn), test runner, debugger, build

local nixCats = require('nixCats')

-- Only load if dotnet category is enabled
if not nixCats.cats["languages.dotnet"] then
  return
end

-- =============================================================================
-- Pin the RPC server (dotnet-easydotnet)
-- =============================================================================
-- easy-dotnet.nvim launches the server via the dotnet muxer (`dotnet easydotnet`,
-- see rpc/server.lua), which resolves `dotnet-easydotnet` from PATH; it exposes no
-- path-override option. The host also auto-updates the global `EasyDotnet` tool in
-- ~/.dotnet/tools, so without intervention nvim runs whatever version the host
-- happens to have -- a moving target that can drift ahead of the plugin commit we
-- pin and tested against (a mismatched server drops/renames RPC routes -> -32601
-- floods, or emits notifications the plugin doesn't handle). We pin a known-good
-- server (packages/easy-dotnet-tool.nix, matched to the plugin pin) and force it
-- to win here for reproducibility.
--
-- nixCats APPENDS its runtime deps to PATH, so the pinned server's bin dir already
-- sits near the END of PATH while the user's ~/.dotnet/tools sits near the FRONT --
-- meaning the host's global would still win. We must force the pinned bin to the
-- front. A "prepend only if absent" guard does NOT work: the dir is already
-- present (appended by lspsAndRuntimeDeps), so the guard skips and the entry never
-- moves ahead of ~/.dotnet/tools. Strip every existing occurrence, then prepend,
-- so the pinned server resolves first for both the launch and any version probe.
local server_bin = nixCats.extra and nixCats.extra.easyDotnetServerBin
if server_bin and vim.fn.isdirectory(server_bin) == 1 then
  local kept = {}
  for _, p in ipairs(vim.split(vim.env.PATH or '', ':', { plain = true })) do
    if p ~= server_bin then
      kept[#kept + 1] = p
    end
  end
  vim.env.PATH = server_bin .. ':' .. table.concat(kept, ':')
end

-- =============================================================================
-- Easy-dotnet Setup (LSP + test runner + debugger + build)
-- =============================================================================

-- Capabilities (with blink.cmp integration)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_blink, blink = pcall(require, 'blink.cmp')
if ok_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- Cap Roslyn's memory footprint. Roslyn has been observed to consume all
-- available RAM on this machine.
--
-- NOTE: easy-dotnet's lsp.enable() rewrites vim.lsp.config[easy_dotnet] and
-- hard-resets cmd_env to {}, so setting cmd_env here is a no-op. Instead we
-- set these on the nvim process environment; the LSP subprocess inherits
-- them because easy-dotnet's empty cmd_env leaves process env untouched.
--
-- DOTNET_GCHeapHardLimit is in bytes (hex). 0x300000000 = 12 GiB.
-- Set DOTNET_GCConserveMemory to 0 (disabled) to avoid GC thrashing that
-- causes extreme latency on hover/definition requests.
vim.env.DOTNET_GCHeapHardLimit = vim.env.DOTNET_GCHeapHardLimit or "0x300000000"
vim.env.DOTNET_gcServer = vim.env.DOTNET_gcServer or "1"

-- Pre-configure the easy_dotnet LSP with our settings before easy-dotnet.setup()
-- This gets merged in by easy-dotnet's lsp.enable() via vim.lsp.config
vim.lsp.config("easy_dotnet", {
  capabilities = capabilities,
  settings = {
    ["csharp|background_analysis"] = {
      dotnet_analyzer_diagnostics_scope = "openFiles",
      dotnet_compiler_diagnostics_scope = "openFiles",
    },
    ["csharp|completion"] = {
      dotnet_provide_regex_completions = true,
      dotnet_show_completion_items_from_unimported_namespaces = true,
      dotnet_show_name_completion_suggestions = true,
    },
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
      csharp_enable_inlay_hints_for_lambda_parameter_types = true,
      csharp_enable_inlay_hints_for_types = true,
      dotnet_enable_inlay_hints_for_indexer_parameters = true,
      dotnet_enable_inlay_hints_for_literal_parameters = true,
      dotnet_enable_inlay_hints_for_object_creation_parameters = true,
      dotnet_enable_inlay_hints_for_other_parameters = true,
      dotnet_enable_inlay_hints_for_parameters = true,
      dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
    },
  },
})

require("easy-dotnet").setup({
  -- Enable built-in Roslyn LSP
  lsp = {
    enabled = true,
    preload_roslyn = true,
    roslynator_enabled = true,
    easy_dotnet_analyzer_enabled = true,
    auto_refresh_codelens = true,
  },

  -- Debugger
  debugger = {
    auto_register_dap = true,
    apply_value_converters = true,
    console = "integratedTerminal",
  },

  -- Test runner (v2 - removed noBuild, enable_buffer_test_execution)
  test_runner = {
    viewmode = "float",
  },

  -- Keep telescope
  picker = "telescope",

  -- Other settings
  auto_bootstrap_namespace = { enabled = false },
})

-- Roslyn registers capabilities dynamically via client/registerCapability after
-- solution load. Declare standard capabilities upfront so nvim allows requests
-- (like gd) before the dynamic registration completes.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('DotnetLspAttach', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= 'easy_dotnet' then
      return
    end
    local sc = client.server_capabilities
    sc.definitionProvider = sc.definitionProvider or true
    sc.referencesProvider = sc.referencesProvider or true
    sc.implementationProvider = sc.implementationProvider or true
    sc.typeDefinitionProvider = sc.typeDefinitionProvider or true

    if sc.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
  end,
})

-- =============================================================================
-- DAP Setup
-- =============================================================================

-- Load .vscode/launch.json when DAP is first required
local launch_json_loaded = false
local function ensure_launch_json()
  if launch_json_loaded then return end
  launch_json_loaded = true
  if vim.fn.filereadable('.vscode/launch.json') == 1 then
    local ok, dap_vscode = pcall(require, 'dap.ext.vscode')
    if ok then
      dap_vscode.load_launchjs(nil, { coreclr = { 'cs' } })
    end
  end
end

-- =============================================================================
-- Keybindings (dotnet-specific)
-- =============================================================================

local function setup_dotnet_keymaps()
  local opts = { buffer = true }
  -- Dotnet commands under <leader>lb
  vim.keymap.set("n", "<leader>lbe", "<cmd>Dotnet<CR>", vim.tbl_extend("force", opts, { desc = "Dotnet commands" }))
  vim.keymap.set("n", "<leader>lbb", "<cmd>Dotnet build quickfix<CR>", vim.tbl_extend("force", opts, { desc = "Build (quickfix)" }))
  vim.keymap.set("n", "<leader>lbr", "<cmd>Dotnet restore<CR>", vim.tbl_extend("force", opts, { desc = "Restore" }))
  vim.keymap.set("n", "<leader>lbc", "<cmd>Dotnet clean<CR>", vim.tbl_extend("force", opts, { desc = "Clean" }))
  vim.keymap.set("n", "<leader>lbt", "<cmd>Dotnet testrunner<CR>", vim.tbl_extend("force", opts, { desc = "Test runner" }))
  vim.keymap.set("n", "<leader>lbd", function()
    ensure_launch_json()
    vim.cmd("Dotnet debug")
  end, vim.tbl_extend("force", opts, { desc = "Debug" }))
end

-- Set up keymaps for C# and project files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cs", "csproj", "fsproj", "sln" },
  callback = setup_dotnet_keymaps,
})

-- Ensure csproj/fsproj/sln are recognized as xml for treesitter
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.csproj", "*.fsproj", "*.props", "*.targets" },
  callback = function()
    vim.bo.filetype = "xml"
    setup_dotnet_keymaps()
  end,
})
