
local M = {}
function M.setup()
	return languages
end

function M.add_language(languages)
	table.insert(languages, "sql")
end

return M
