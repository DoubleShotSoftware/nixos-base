vim.api.nvim_create_augroup("fmt", { clear = true })
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   group = "fmt",
--   pattern = "*",
--   callback = function()
--     -- vim.cmd("undojoin")
--     vim.cmd("Neoformat")
--   end,
-- })
