-- Function to create a popup window with content
_G.create_popup = function(content)
	local Popup = require("nui.popup")

	local popup = Popup({
		position = "50%",
		size = {
			width = "80%",
			height = "60%",
		},
		border = {
			style = "rounded",
			text = {
				top = " Output ",
				top_align = "center",
			},
		},
		win_options = {
			winblend = 10,
			winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		},
	})

	-- Mount the popup and set the content
	popup:mount()
	popup:on("BufLeave", function()
		popup:unmount()
	end)

	-- Set the buffer content
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, content)
end

-- Function to run a command and display its output in a popup
_G.show_command_output = function(command)
	local output = vim.fn.execute(command, "silent")
	local lines = vim.split(output, "\n", { trimempty = true })
	create_popup(lines)
end
