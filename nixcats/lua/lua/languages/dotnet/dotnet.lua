-- nixcats/lua/lua/languages/dotnet/dotnet.lua
-- .NET development setup using easy-dotnet

local nixCats = require('nixCats')

-- Only load if dotnet category is enabled
if not nixCats.cats["languages.dotnet"] then
  return
end

-- Easy-dotnet setup (includes built-in Roslyn LSP)
require("easy-dotnet").setup({
  -- LSP enabled, settings come from lsp/easy_dotnet.lua
  lsp = {
    enabled = true,
    roslynator_enabled = true,
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

  -- Other settings
  auto_bootstrap_namespace = { enabled = false },
})

-- Keybindings (buffer-local for cs/csproj files)
local function setup_dotnet_keymaps()
  local opts = { buffer = true }
  vim.keymap.set("n", "<leader>lbe", "<cmd>Dotnet<CR>", vim.tbl_extend("force", opts, { desc = "Dotnet commands" }))
  vim.keymap.set("n", "<leader>lbb", "<cmd>Dotnet build quickfix<CR>", vim.tbl_extend("force", opts, { desc = "Build (quickfix)" }))
  vim.keymap.set("n", "<leader>lbr", "<cmd>Dotnet restore<CR>", vim.tbl_extend("force", opts, { desc = "Restore" }))
  vim.keymap.set("n", "<leader>lbc", "<cmd>Dotnet clean<CR>", vim.tbl_extend("force", opts, { desc = "Clean" }))
  vim.keymap.set("n", "<leader>lbt", "<cmd>Dotnet testrunner<CR>", vim.tbl_extend("force", opts, { desc = "Test runner" }))
  vim.keymap.set("n", "<leader>lbd", "<cmd>Dotnet debug<CR>", vim.tbl_extend("force", opts, { desc = "Debug" }))
end

-- Set up keymaps for C# and project files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cs", "csproj", "fsproj" },
  callback = setup_dotnet_keymaps,
})
