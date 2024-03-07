local M = {}
M.methods = {}
local ts_utils = require('nvim-treesitter.ts_utils')
function M.add_language(languages) 
    table.insert(languages, { 
        "javascript",
        "jsdoc",
        "tsx",
        "typescript"	
    })
end
return M
