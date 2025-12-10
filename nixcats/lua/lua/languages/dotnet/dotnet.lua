-- nixcats/lua/lua/plugins/dotnet.lua
-- .NET development setup: roslyn.nvim + easy-dotnet

local nixCats = require('nixCats')

-- Only load if dotnet category is enabled
if not nixCats.cats["languages.dotnet"] then
  return
end

-- Get paths from nixCats extra
local roslynDLLPath = nixCats.extra.roslynDLLPath
local roslynDotnetPath = nixCats.extra.roslynDotnetPath

-- Roslyn LSP setup
require("roslyn").setup({
  config = {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
    cmd = {
      roslynDotnetPath, roslynDLLPath, "--stdio", "--telemetryLevel=off",
      "--logLevel=Debug",
      "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path())
    }
  },
  filewatching = "auto",
  settings = {
    ["csharp|background_analysis"] = {
      dotnet_analyzer_diagnostics_scope = "fullSolution",
      dotnet_compiler_diagnostics_scope = "fullSolution"
    },
    ["csharp|completion"] = {
      dotnet_provide_regex_completions = true,
      dotnet_show_completion_items_from_unimported_namespaces = true,
      dotnet_show_name_completion_suggestions = true
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
      dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true
    },
    ["csharp|code_lens"] = { dotnet_enable_references_code_lens = true }
  }
})

-- Easy-dotnet setup
require("easy-dotnet").setup({
  picker = "telescope",
  server = { use_visual_studio = false },
  auto_bootstrap_namespace = { enabled = false },
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
})

-- Keybindings (buffer-local for cs/csproj files)
local function setup_dotnet_keymaps()
  local opts = { buffer = true }
  vim.keymap.set("n", "<leader>lbe", "<cmd>Dotnet<CR>", vim.tbl_extend("force", opts, { desc = "Dotnet commands" }))
  vim.keymap.set("n", "<leader>lbb", "<cmd>Dotnet build quickfix<CR>", vim.tbl_extend("force", opts, { desc = "Build (quickfix)" }))
  vim.keymap.set("n", "<leader>lbr", "<cmd>Dotnet restore<CR>", vim.tbl_extend("force", opts, { desc = "Restore" }))
  vim.keymap.set("n", "<leader>lbc", "<cmd>Dotnet clean<CR>", vim.tbl_extend("force", opts, { desc = "Clean" }))
  vim.keymap.set("n", "<leader>lbt", "<cmd>Dotnet testrunner<CR>", vim.tbl_extend("force", opts, { desc = "Test runner" }))
  vim.keymap.set("n", "<leader>lbf", "<cmd>split | terminal dotnet format<CR>", vim.tbl_extend("force", opts, { desc = "Format" }))
end

-- Set up keymaps for C# and project files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cs", "csproj", "fsproj" },
  callback = setup_dotnet_keymaps,
})
