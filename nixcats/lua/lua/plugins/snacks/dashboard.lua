-- nixcats/lua/plugins/snacks/dashboard.lua
-- Snacks dashboard configuration

return {
  enabled = true,
  preset = {
    keys = {
      { icon = '󰈔 ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
      { icon = '󰋚 ', key = 'r', desc = 'Recent Files', action = ':Telescope oldfiles' },
      { icon = '󰈞 ', key = 'f', desc = 'Find File', action = ':Telescope find_files' },
      { icon = '󰊄 ', key = 'g', desc = 'Live Grep', action = ':Telescope live_grep' },
      { icon = '󰊢 ', key = 'h', desc = 'Git Status', action = function() Snacks.lazygit() end },
      { icon = '󱖫 ', key = 't', desc = 'Todo Comments', action = ':TodoTelescope' },
      { icon = '󰋼 ', key = 'd', desc = 'Diagnostics', action = ':Trouble diagnostics toggle' },
      { icon = '󰩈 ', key = 'q', desc = 'Quit', action = ':qa' },
    },
  },
  sections = {
    { section = 'header' },
    { section = 'keys', gap = 1, padding = 1 },
    {
      pane = 2,
      icon = '󰋚 ',
      title = 'Recent Files',
      section = 'recent_files',
      indent = 2,
      padding = 1,
    },
    {
      pane = 2,
      icon = '󰉋 ',
      title = 'Projects',
      section = 'projects',
      indent = 2,
      padding = 1,
    },
    {
      pane = 2,
      icon = '󰊢 ',
      title = 'Git Status',
      section = 'terminal',
      enabled = function()
        return Snacks.git.get_root() ~= nil
      end,
      cmd = 'git status --short --branch --renames',
      height = 5,
      padding = 1,
      ttl = 5 * 60,
      indent = 3,
    }
  },
}
