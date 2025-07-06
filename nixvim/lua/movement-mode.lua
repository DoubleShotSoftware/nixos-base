local M = {}

-- Debug: Indicate module is loaded
print("Movement-mode module loaded!")

-- Define the mapping of QWERTY keys to numbers
local key_to_number = {
  ["q"] = "1",
  ["w"] = "2",
  ["e"] = "3",
  ["r"] = "4",
  ["t"] = "5",
  ["y"] = "6",
  ["u"] = "7",
  ["i"] = "8",
  ["o"] = "9",
  ["p"] = "0",
}

-- Stores the key sequence being built
local number_sequence = ""

-- Flag to track if we're in movement mode
local in_movement_mode = false

-- Function to enter movement mode
function M.enter_movement_mode()
  -- Check if we're in a normal buffer that allows movement
  local buffer_type = vim.bo.buftype
  if buffer_type == 'nofile' or buffer_type == 'quickfix' or buffer_type == 'help' or not vim.bo.modifiable then
    require('snacks').notify("Movement mode cannot be used in " .. (buffer_type ~= '' and buffer_type or "non-modifiable") .. " buffer",
      { title = "Movement Mode", level = "warn" })
    return
  end

  in_movement_mode = true
  number_sequence = ""
  -- Show indicator that we're in movement mode using Snacks
  require('snacks').notify("Movement mode active", { title = "Movement Mode", level = "info" })

  -- Setup temporary mappings for all the top row keys
  for key, num in pairs(key_to_number) do
    vim.keymap.set('n', key, function()
      M.handle_number_key(num)
    end, { noremap = true, silent = true, desc = "Movement mode: append " .. num })
  end

  -- Movement keys
  vim.keymap.set('n', 'j', function() M.execute_movement('j') end, { noremap = true, silent = true, desc = "Movement mode: move down" })
  vim.keymap.set('n', 'k', function() M.execute_movement('k') end, { noremap = true, silent = true, desc = "Movement mode: move up" })
  vim.keymap.set('n', 'h', function() M.execute_movement('h') end, { noremap = true, silent = true, desc = "Movement mode: move left" })
  vim.keymap.set('n', 'l', function() M.execute_movement('l') end, { noremap = true, silent = true, desc = "Movement mode: move right" })
  vim.keymap.set('n', 'G', function() M.execute_movement('G') end, { noremap = true, silent = true, desc = "Movement mode: go to line" })
  vim.keymap.set('n', 'gg', function() M.execute_movement('gg') end, { noremap = true, silent = true, desc = "Movement mode: go to start" })

  -- Other common movement commands
  vim.keymap.set('n', 'f', function() M.execute_movement('f') end, { noremap = true, silent = true, desc = "Movement mode: find forward" })
  vim.keymap.set('n', 'F', function() M.execute_movement('F') end, { noremap = true, silent = true, desc = "Movement mode: find backward" })
  vim.keymap.set('n', 't', function() M.execute_movement('t') end, { noremap = true, silent = true, desc = "Movement mode: till forward" })
  vim.keymap.set('n', 'T', function() M.execute_movement('T') end, { noremap = true, silent = true, desc = "Movement mode: till backward" })

  -- Escape movement mode with Escape or 'm' again
  vim.keymap.set('n', '<Esc>', M.exit_movement_mode, { noremap = true, silent = true, desc = "Exit movement mode" })
  vim.keymap.set('n', 'm', M.exit_movement_mode, { noremap = true, silent = true, desc = "Exit movement mode" })
end

-- Function to handle number key presses
function M.handle_number_key(num)
  number_sequence = number_sequence .. num
  -- Provide visual feedback of the number sequence using Snacks
  require('snacks').notify(number_sequence, {
    title = "Movement Mode",
    level = "info",
    timeout = 1500  -- Short timeout since this updates frequently
  })
end

-- Function to execute the movement command
function M.execute_movement(move_cmd)
  local cmd = ""
  if number_sequence ~= "" then
    cmd = number_sequence .. move_cmd
  else
    cmd = move_cmd
  end

  -- Notify about the command being executed
  if number_sequence ~= "" then
    require('snacks').notify("Executing " .. cmd, {
      title = "Movement Mode",
      level = "info",
      timeout = 1000
    })
  end

  -- Execute the command
  local success, err = pcall(function()
    -- Check if we're in a buffer where we can execute commands
    if not vim.bo.modifiable and cmd ~= 'h' and cmd ~= 'j' and cmd ~= 'k' and cmd ~= 'l' and cmd ~= 'gg' and cmd ~= 'G' then
      error("Cannot execute '" .. cmd .. "' in non-modifiable buffer")
    end

    vim.cmd("normal! " .. cmd)
  end)

  -- Log any error
  if not success then
    require('snacks').notify("Error: " .. tostring(err), {
      title = "Movement Mode",
      level = "error",
      timeout = 3000
    })
    print("Movement mode error executing command: " .. cmd .. " - " .. tostring(err))
  end

  -- Exit movement mode
  M.exit_movement_mode(false)
end

-- Function to exit movement mode
function M.exit_movement_mode(notify)
  if not in_movement_mode then
    return
  end

  -- Clear movement mode state
  in_movement_mode = false

  -- Notify if requested (true by default)
  if notify ~= false then
    require('snacks').notify("Movement mode exited", {
      title = "Movement Mode",
      level = "info",
      timeout = 1500
    })
  end
  
  -- Remove all the temporary mappings with pcall to avoid errors
  for key, _ in pairs(key_to_number) do
    pcall(vim.keymap.del, 'n', key)
  end

  -- Remove movement key mappings with pcall to avoid errors
  pcall(vim.keymap.del, 'n', 'j')
  pcall(vim.keymap.del, 'n', 'k')
  pcall(vim.keymap.del, 'n', 'h')
  pcall(vim.keymap.del, 'n', 'l')
  pcall(vim.keymap.del, 'n', 'G')
  pcall(vim.keymap.del, 'n', 'gg')
  pcall(vim.keymap.del, 'n', 'f')
  pcall(vim.keymap.del, 'n', 'F')
  pcall(vim.keymap.del, 'n', 't')
  pcall(vim.keymap.del, 'n', 'T')
  pcall(vim.keymap.del, 'n', '<Esc>')
  pcall(vim.keymap.del, 'n', 'm')
end

-- Function to check if we're in movement mode
function M.is_active()
  return in_movement_mode
end

-- Setup function
function M.setup()
  -- Debug: Print setup function is called
  print("Movement-mode setup function called!")

  -- Register the main keymap to enter movement mode
  vim.keymap.set('n', 'm', M.enter_movement_mode, { noremap = true, silent = true, desc = "Enter movement mode" })

  -- Debug: Confirm keymap is set
  print("Movement-mode keymap set: 'm' -> enter_movement_mode")

  -- Debug: List all keymaps to check if 'm' is properly set
  vim.defer_fn(function()
    print("Movement-mode debug: Checking keymaps...")
    local keymaps = vim.api.nvim_get_keymap('n')
    for _, keymap in ipairs(keymaps) do
      if keymap.lhs == 'm' then
        print("Found 'm' keymap: " .. vim.inspect(keymap))
      end
    end

    -- Test setting a dummy keymap
    vim.keymap.set('n', '<F12>', function() print("Test keymap works!") end, { desc = "Test keymap" })
    print("Set test keymap on F12 - please try pressing F12 to test keymap system")
  end, 1000)  -- Check after 1 second to ensure everything is loaded
end

return M