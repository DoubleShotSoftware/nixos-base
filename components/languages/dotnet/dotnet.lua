local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	vim.notify("Couldn't load LSP-Config" .. lspconfig, "error")
	return
end

local lsp_handler = require("user.lsp.handlers")
if not status_ok then
	print("LSP Is not ok in omnisharp")
	return
end

local dotnetPaths = require("user.lsp.settings.dotnetpaths")
local pid = vim.fn.getpid()
local config = {
	on_attach = on_attach,
	cmd = {
		dotnetPaths.OmniSharp,
	},
	-- Enables support for reading code style, naming convention and analyzer
	-- settings from .editorconfig.
	enable_editorconfig_support = true,
	-- If true, MSBuild project system will only load projects for files that
	-- were opened in the editor. This setting is useful for big C# codebases
	-- and allows for faster initialization of code navigation features only
	-- for projects that are relevant to code that is being edited. With this
	-- setting enabled OmniSharp may load fewer projects and may thus display
	-- incomplete reference lists for symbols.
	enable_ms_build_load_projects_on_demand = false,
	-- Enables support for roslyn analyzers, code fixes and rulesets.
	enable_roslyn_analyzers = false,
	-- Specifies whether 'using' directives should be grouped and sorted during
	-- document formatting.
	organize_imports_on_format = true,

	-- Enables support for showing unimported types and unimported extension
	-- methods in completion lists. When committed, the appropriate using
	-- directive will be added at the top of the current file. This option can
	-- have a negative impact on initial completion responsiveness,
	-- particularly for the first few completion sessions after opening a
	-- solution.
	enable_import_completion = true,

	-- Specifies whether to include preview versions of the .NET SDK when
	-- determining which version to use for project loading.
	sdk_include_prereleases = true,

	-- Only run analyzers against open files when 'enableRoslynAnalyzers' is
	-- true
	analyze_open_documents_only = false,
}

require("lspconfig")["omnisharp"].setup(config)
local home = os.getenv("HOME")
require("csharp").setup({
	lsp = {
		-- When set to true, csharp.nvim won't install omnisharp automatically and use it via mason.
		-- Instead, the omnisharp instance in the cmd_path will be used.
		cmd_path = home .. "/.bin",
		-- The default timeout when communicating with omnisharp
		default_timeout = 1000,
		-- Settings that'll be passed to the omnisharp server
		enable_editor_config_support = true,
		organize_imports = true,
		load_projects_on_demand = false,
		enable_analyzers_support = true,
		enable_import_completion = true,
		include_prerelease_sdks = true,
		analyze_open_documents_only = false,
		enable_package_auto_restore = true,
	},
	logging = {
		-- The minimum log level.
		level = "DEBUG",
	},
})
