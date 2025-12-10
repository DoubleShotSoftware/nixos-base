require("colorful-menu").setup({
	ls = {
		lua_ls = {
			-- Maybe you want to dim arguments a bit.
			arguments_hl = "@comment",
		},
		gopls = false,		-- for lsp_config or typescript-tools
		ts_ls = {
			-- false means do not include any extra info,
			-- see https://github.com/xzbdmw/colorful-menu.nvim/issues/42
			extra_info_hl = "@comment",
		},
		vtsls = {
			-- false means do not include any extra info,
			-- see https://github.com/xzbdmw/colorful-menu.nvim/issues/42
			extra_info_hl = "@comment",
		},
		["rust-analyzer"] = {
			-- Such as (as Iterator), (use std::io).
			extra_info_hl = "@comment",
			-- Similar to the same setting of gopls.
			align_type_to_right = true,
			-- See https://github.com/xzbdmw/colorful-menu.nvim/pull/36
			preserve_type_when_truncate = true,
		},
		clangd = {
			-- Such as "From <stdio.h>".
			extra_info_hl = "@comment",
			-- Similar to the same setting of gopls.
			align_type_to_right = true,
			-- the hl group of leading dot of "•std::filesystem::permissions(..)"
			import_dot_hl = "@comment",
			-- See https://github.com/xzbdmw/colorful-menu.nvim/pull/36
			preserve_type_when_truncate = true,
		},
		zls = false,
        roslyn = {
			extra_info_hl = "@comment",
		},
		basedpyright = {
			-- It is usually import path such as "os"
			extra_info_hl = "@comment",
		},
		-- If true, try to highlight "not supported" languages.
		fallback = true,
		-- this will be applied to label description for unsupport languages
		fallback_extra_info_hl = "@comment",
	},
	-- If the built-in logic fails to find a suitable highlight group for a label,
	-- this highlight is applied to the label.
	fallback_highlight = "@variable",
})
