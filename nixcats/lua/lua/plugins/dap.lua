-- nixcats/lua/plugins/dap.lua
-- Debug Adapter Protocol configuration and keymaps

local ok, dap = pcall(require, 'dap')
if not ok then
  return
end

-- DAP UI setup
local ok_ui, dapui = pcall(require, 'dapui')
if ok_ui then
  dapui.setup({
    floating = {
      mappings = {
        close = { '<ESC>', 'q' },
      },
    },
  })

  -- Auto open/close UI
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

-- DAP virtual text
local ok_vt, dap_vt = pcall(require, 'nvim-dap-virtual-text')
if ok_vt then
  dap_vt.setup({})
end

-- Keymaps (under <leader>d for Debugger)
local map = vim.keymap.set

-- Core debugging
map('n', '<leader>dc', function() dap.continue() end, { desc = 'Continue' })
map('n', '<leader>db', function() dap.toggle_breakpoint() end, { desc = 'Toggle breakpoint' })
map('n', '<leader>dB', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = 'Conditional breakpoint' })
map('n', '<leader>dl', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, { desc = 'Log point' })

-- Stepping
map('n', '<leader>do', function() dap.step_over() end, { desc = 'Step over' })
map('n', '<leader>di', function() dap.step_into() end, { desc = 'Step into' })
map('n', '<leader>dO', function() dap.step_out() end, { desc = 'Step out' })

-- Control
map('n', '<leader>dr', function() dap.repl.open() end, { desc = 'Open REPL' })
map('n', '<leader>dR', function() dap.run_last() end, { desc = 'Run last' })
map('n', '<leader>dt', function() dap.terminate() end, { desc = 'Terminate' })
map('n', '<leader>dp', function() dap.pause() end, { desc = 'Pause' })

-- UI
if ok_ui then
  map('n', '<leader>du', function() dapui.toggle() end, { desc = 'Toggle UI' })
  map('n', '<leader>de', function() dapui.eval() end, { desc = 'Eval under cursor' })
  map('v', '<leader>de', function() dapui.eval() end, { desc = 'Eval selection' })
end

-- Function keys (alternative bindings)
map('n', '<F5>', function() dap.continue() end, { desc = 'Debug: Continue' })
map('n', '<F9>', function() dap.toggle_breakpoint() end, { desc = 'Debug: Breakpoint' })
map('n', '<F10>', function() dap.step_over() end, { desc = 'Debug: Step over' })
map('n', '<F11>', function() dap.step_into() end, { desc = 'Debug: Step into' })
map('n', '<F12>', function() dap.step_out() end, { desc = 'Debug: Step out' })
