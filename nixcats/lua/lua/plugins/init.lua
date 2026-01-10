-- nixcats/lua/plugins/init.lua
-- Plugin configurations loader

-- Load individual plugin configs
require('plugins.colorscheme')
require('plugins.tabline')
require('plugins.lsp')
require('plugins.completion')
require('plugins.telescope')
require('plugins.treesitter')
require('plugins.git')
require('plugins.ui')
require('plugins.editor')
require('plugins.snacks')

-- Language-specific configs (guarded by nixCats categories)
require('languages')
