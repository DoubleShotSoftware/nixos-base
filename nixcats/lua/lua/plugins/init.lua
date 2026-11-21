-- nixcats/lua/plugins/init.lua
-- Plugin configurations loader

-- Load individual plugin configs
require('plugins.colorscheme')
require('plugins.tabline')
require('plugins.lsp')
require('plugins.completion')
require('plugins.telescope')
require('plugins.treesitter')
require('plugins.folding')
require('plugins.git')
require('plugins.ui')
require('plugins.editor')
require('plugins.snacks')
-- require('plugins.copilot')
require('plugins.formatting')
require('plugins.codediff')
-- require('plugins.precognition')
-- require('plugins.hardtime')

-- Language-specific configs (guarded by nixCats categories)
require('languages')

-- DAP (only if a debuggable language is enabled)
local nixCats = require('nixCats')
if nixCats.cats["languages.dotnet"] then
  require('plugins.dap')
end
