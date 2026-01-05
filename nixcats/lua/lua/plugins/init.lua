-- nixcats/lua/plugins/init.lua
-- Plugin configurations loader

-- Load snacks FIRST - must be before UIEnter for dashboard to work
require('plugins.snacks')

-- Load individual plugin configs
require('plugins.colorscheme')
require('plugins.tabline')
require('plugins.lsp')
require('plugins.conform')
require('plugins.completion')
require('plugins.telescope')
require('plugins.treesitter')
require('plugins.git')
require('plugins.git_worktree')
require('plugins.ui')
require('plugins.ui-extras')
require('plugins.editor')
require('plugins.ufo')
require('plugins.avante')
require('plugins.copilot')
require('plugins.illuminate')
require('plugins.smart-splits')
require('plugins.lint')
require('plugins.zellij-nav')
require('plugins.dap')

-- Language-specific configs (guarded by nixCats categories)
require('languages')
