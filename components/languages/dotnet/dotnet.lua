local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	vim.notify("Couldn't load LSP-Config" .. lspconfig, "error")
	return
end
local home = os.getenv("HOME")

local lsp_handler = require("user.lsp.handlers")
local dotnetPaths = require("user.lsp.settings.dotnetpaths")
local pid = vim.fn.getpid()
local config = {
	on_attach = lsp_handler.on_attach,
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

require("lspconfig")["csharp_ls"].setup({
	{
		cmd = {
			dotnetPaths.CSharpLS,
		},
		handlers = {
			["textDocument/definition"] = require("csharpls_extended").handler,
			["textDocument/typeDefinition"] = require("csharpls_extended").handler,
		},
	},
})
