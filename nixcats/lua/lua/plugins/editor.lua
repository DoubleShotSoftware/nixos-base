-- nixcats/lua/plugins/editor.lua
-- Editor enhancement plugins

-- Comment.nvim
require('Comment').setup({})

-- Autopairs
require('nvim-autopairs').setup({
  check_ts = true,
  ts_config = {
    lua = { 'string' },
    javascript = { 'template_string' },
  },
})

-- Flash (navigation)
require('flash').setup({
  labels = 'asdfghjklqwertyuiopzxcvbnm',
  search = {
    mode = 'exact',
    incremental = true,
  },
  jump = {
    jumplist = true,
    pos = 'start',
    history = false,
    register = false,
    nohlsearch = false,
    autojump = false,
  },
  modes = {
    char = {
      enabled = true,
      jump_labels = true,
      keys = { 'f', 'F', 't', 'T', ';', ',' },
    },
    search = {
      enabled = true,
    },
  },
})

vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash Treesitter' })
vim.keymap.set('o', 'r', function() require('flash').remote() end, { desc = 'Remote Flash' })
vim.keymap.set({ 'o', 'x' }, 'R', function() require('flash').treesitter_search() end, { desc = 'Treesitter Search' })

-- Mini.nvim modules
require('mini.ai').setup()        -- Better text objects
require('mini.surround').setup()  -- Surround actions
require('mini.bufremove').setup() -- Better buffer removal

-- Override buffer close to use mini.bufremove
vim.keymap.set('n', '<leader>bc', function()
  require('mini.bufremove').delete(0, false)
end, { desc = 'Close buffer' })
vim.keymap.set('n', '<leader>bC', function()
  require('mini.bufremove').delete(0, true)
end, { desc = 'Force close buffer' })

-- Snacks.nvim is configured in plugins/snacks/init.lua

-- Render-markdown (markdown preview in buffer)
require('render-markdown').setup({
  enabled = true,
  render_modes = { 'n', 'c' },
  heading = {
    enabled = true,
    icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
  },
  code = {
    enabled = true,
    style = 'full',
    border = 'thin',
    language_pad = 2,
  },
  bullet = {
    enabled = true,
    icons = { '●', '○', '◆', '◇' },
  },
  checkbox = {
    enabled = true,
    unchecked = { icon = '󰄱 ' },
    checked = { icon = '󰱒 ' },
  },
})
