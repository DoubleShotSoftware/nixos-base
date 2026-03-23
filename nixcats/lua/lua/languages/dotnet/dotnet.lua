-- nixcats/lua/lua/languages/dotnet/dotnet.lua
-- .NET development setup
-- roslyn.nvim for LSP (better diagnostics), easy-dotnet for test/debug/build

local nixCats = require('nixCats')

-- Only load if dotnet category is enabled
if not nixCats.cats["languages.dotnet"] then
  return
end

-- =============================================================================
-- Roslyn LSP Setup (using roslyn.nvim)
-- =============================================================================

-- Common capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_blink, blink = pcall(require, 'blink.cmp')
if ok_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- Roslyn.nvim setup
require('roslyn').setup({
  config = {
    capabilities = capabilities,
  },
  -- File watching mode: "auto" uses neovim's built-in file watching
  filewatching = "auto",
  -- Settings matching nixvim config
  settings = {
    ["csharp|background_analysis"] = {
      dotnet_analyzer_diagnostics_scope = "fullSolution",
      dotnet_compiler_diagnostics_scope = "fullSolution",
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

-- Roslyn-specific LspAttach for inlay hints
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('RoslynLspAttach', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= 'roslyn' then
      return
    end
    -- Enable inlay hints if supported
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
  end,
})

-- =============================================================================
-- Easy-dotnet Setup (test runner, debugger, build commands - NO LSP)
-- =============================================================================

require("easy-dotnet").setup({
  -- DISABLE built-in LSP - using roslyn.nvim instead
  lsp = {
    enabled = false,
  },

  -- Zero-config debugging with bundled NetCoreDbg
  debugger = {
    auto_register_dap = true,
    apply_value_converters = true,
  },

  -- Test runner with buffer execution
  test_runner = {
    viewmode = "float",
    enable_buffer_test_execution = true,
    noBuild = true,
  },

  -- Keep telescope
  picker = "telescope",

  -- Terminal configuration for build output
  terminal = function(path, action, args, ctx)
    args = args or ""
    local commands = {
      run = function() return string.format("%s %s", ctx.cmd, args) end,
      test = function() return string.format("%s %s", ctx.cmd, args) end,
      restore = function() return string.format("%s %s", ctx.cmd, args) end,
      build = function() return string.format("%s %s", ctx.cmd, args) end,
      watch = function() return string.format("dotnet watch --project %s %s", path, args) end,
    }
    local command = commands[action]()
    vim.cmd("vsplit")
    vim.cmd("term " .. command)
  end,

  -- Other settings
  auto_bootstrap_namespace = { enabled = false },
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
-- Keybindings (dotnet-specific, NOT overriding <leader>bf)
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
