-- nixcats/lua/plugins/dap.lua
-- Debug Adapter Protocol configuration

local dap_ok, dap = pcall(require, 'dap')
if not dap_ok then
  return
end

local dapui_ok, dapui = pcall(require, 'dapui')
local dap_virtual_text_ok, dap_virtual_text = pcall(require, 'nvim-dap-virtual-text')

-- DAP UI setup
if dapui_ok then
  dapui.setup({
    icons = { expanded = '', collapsed = '', current_frame = '' },
    mappings = {
      expand = { '<CR>', '<2-LeftMouse>' },
      open = 'o',
      remove = 'd',
      edit = 'e',
      repl = 'r',
      toggle = 't',
    },
    layouts = {
      {
        elements = {
          { id = 'scopes', size = 0.25 },
          { id = 'breakpoints', size = 0.25 },
          { id = 'stacks', size = 0.25 },
          { id = 'watches', size = 0.25 },
        },
        size = 40,
        position = 'left',
      },
      {
        elements = {
          { id = 'repl', size = 0.5 },
          { id = 'console', size = 0.5 },
        },
        size = 10,
        position = 'bottom',
      },
    },
    floating = {
      border = 'rounded',
    },
  })

  -- Auto open/close DAP UI
  dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated['dapui_config'] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited['dapui_config'] = function()
    dapui.close()
  end
end

-- Virtual text setup
if dap_virtual_text_ok then
  dap_virtual_text.setup({
    enabled = true,
    enabled_commands = true,
    highlight_changed_variables = true,
    highlight_new_as_changed = false,
    show_stop_reason = true,
    commented = false,
    virt_text_pos = 'eol',
  })
end

-- DAP signs
vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DiagnosticError', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = 'DiagnosticWarn', linehl = '', numhl = '' })
vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DiagnosticInfo', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '', texthl = 'DiagnosticOk', linehl = 'DapStoppedLine', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DiagnosticError', linehl = '', numhl = '' })

-- Highlight for stopped line
vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#3d4220' })

-- Keymaps
local map = vim.keymap.set

-- Breakpoints
map('n', '<leader>db', function() dap.toggle_breakpoint() end, { desc = 'Toggle breakpoint' })
map('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'Conditional breakpoint' })
map('n', '<leader>dl', function()
  dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
end, { desc = 'Log point' })

-- Execution
map('n', '<leader>dc', function() dap.continue() end, { desc = 'Continue' })
map('n', '<leader>dC', function() dap.run_to_cursor() end, { desc = 'Run to cursor' })
map('n', '<leader>ds', function() dap.step_over() end, { desc = 'Step over' })
map('n', '<leader>di', function() dap.step_into() end, { desc = 'Step into' })
map('n', '<leader>do', function() dap.step_out() end, { desc = 'Step out' })
map('n', '<leader>dp', function() dap.pause() end, { desc = 'Pause' })

-- Session
map('n', '<leader>dr', function() dap.restart() end, { desc = 'Restart' })
map('n', '<leader>dt', function() dap.terminate() end, { desc = 'Terminate' })
map('n', '<leader>dd', function() dap.disconnect() end, { desc = 'Disconnect' })

-- UI
if dapui_ok then
  map('n', '<leader>du', function() dapui.toggle() end, { desc = 'Toggle DAP UI' })
  map('n', '<leader>de', function() dapui.eval() end, { desc = 'Eval expression' })
  map('v', '<leader>de', function() dapui.eval() end, { desc = 'Eval selection' })
end

-- REPL
map('n', '<leader>dR', function() dap.repl.toggle() end, { desc = 'Toggle REPL' })

-- Register which-key group
local wk_ok, wk = pcall(require, 'which-key')
if wk_ok then
  wk.add({
    { '<leader>d', group = 'Debug' },
  })
end
