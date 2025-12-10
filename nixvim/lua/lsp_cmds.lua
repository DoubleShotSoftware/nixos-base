-- Function to run a command and capture its output
local function run_health_check()
  local output_lines = {}

  -- Temporarily capture output to a scratch buffer
  vim.api.nvim_exec(
    [[
    silent! set nomore
    redir => g:health_output
    checkhealth
    redir END
    silent! set more
    ]],
    false
  )

  -- Get the output from the global variable
  local output = vim.api.nvim_get_var("health_output")

  -- Split the output into lines
  output_lines = vim.split(output, "\n", { trimempty = true })

  -- Cleanup the temporary variable
  vim.api.nvim_del_var("health_output")

  return output_lines
end

vim.api.nvim_create_user_command("LspPopupInfo", function()
  show_command_output("LspInfo")
end, {})

vim.api.nvim_create_user_command("LspPopupHealth", function()
  local content = run_health_check()
  create_popup(content)
end, {})
