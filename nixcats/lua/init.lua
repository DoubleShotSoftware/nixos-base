-- nixcats/lua/init.lua
-- Entry point for nixCats-based Neovim configuration

-- Load nixCats utility (provides category checking)
local nixCats = require('nixCats')

-- Load core configuration
require('core.options')
require('core.keymaps')

-- Load plugin configurations
require('plugins')
require('languages')

-- Print enabled languages for debugging (only in dev mode)
if nixCats('extra.enabledLanguages') then
  local langs = nixCats('extra.enabledLanguages')
  if type(langs) == 'table' and #langs > 0 then
    vim.notify('nixCats loaded with languages: ' .. table.concat(langs, ', '), vim.log.levels.INFO)
  end
end
