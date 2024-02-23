local M = {}
function M.setup()
	return languages
end

function M.add_language(languages)
	table.insert(languages, "json")
end

return M
