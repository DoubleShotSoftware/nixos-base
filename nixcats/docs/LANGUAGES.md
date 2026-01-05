# Language Modules

nixcats uses a modular language system where each language has its own Nix module defining LSPs, formatters, and tools.

## How Language Modules Work

Each module in `languages/` exports a structured configuration:

```nix
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = [ ... ];  # LSPs, formatters, CLI tools
  startupPlugins = [ ... ];      # Always-loaded plugins
  optionalPlugins = [ ... ];     # Lazy-loaded plugins
  environmentVariables = { };     # Environment variables
  extra = { };                    # Data passed to Lua
}
```

Languages are enabled via the `languages` parameter:

```nix
mkNixCats {
  languages = [ "nix" "dotnet" "rust" ];
}
```

This creates nixCats categories accessible in Lua:

```lua
if nixCats.cats["languages.dotnet"] then
  -- dotnet-specific setup
end
```

---

## Available Languages

### Nix

**File**: `languages/nix.nix`

| Component | Package |
|-----------|---------|
| LSP | nixd |
| LSP (alt) | nil |
| Formatter | alejandra |
| Formatter (alt) | nixfmt-rfc-style |
| Linter | statix |
| Linter | deadnix |

**Features**:
- Full nixd language server with completion and diagnostics
- Formatting via alejandra (fast, opinionated)
- Static analysis with statix and deadnix

---

### .NET / C#

**File**: `languages/dotnet.nix`

| Component | Package |
|-----------|---------|
| LSP | roslyn-ls (via easy-dotnet) |
| Formatter | csharpier |
| Debugger | netcoredbg |
| Tools | dotnet-ef, nuget |
| Plugin | easy-dotnet-nvim |

**Features**:
- Full Roslyn-based language server
- Zero-config debugging with DAP
- Test runner integration
- NuGet package management
- Solution/project navigation

**Keybindings** (in .cs files):
- `<leader>lbe` - Dotnet commands menu
- `<leader>lbb` - Build with quickfix
- `<leader>lbt` - Test runner
- `<leader>lbd` - Debug

---

### Rust

**File**: `languages/rust.nix`

| Component | Package |
|-----------|---------|
| LSP | rust-analyzer |
| Formatter | rustfmt |
| Linter | clippy |
| Plugin | rustaceanvim |
| Plugin | crates-nvim |

**Features**:
- Full rust-analyzer via rustaceanvim
- Inline type hints and diagnostics
- Cargo.toml dependency management (crates-nvim)
- Integrated debugging

---

### Python

**File**: `languages/python.nix`

| Component | Package |
|-----------|---------|
| LSP | pyright |
| Formatter | ruff |
| Formatter | black |
| Tool | isort |
| Plugin (opt) | nvim-dap-python |

**Features**:
- Type checking with pyright
- Fast linting/formatting with ruff
- Import sorting with isort
- Debug support via nvim-dap-python

---

### TypeScript / JavaScript

**File**: `languages/typescript.nix`

| Component | Package |
|-----------|---------|
| LSP | ts_ls (typescript-language-server) |
| LSP | eslint |
| Formatter | prettier |

**Features**:
- Full TypeScript/JavaScript support
- ESLint integration for linting
- Prettier formatting
- JSX/TSX support

---

### JSON

**File**: `languages/json.nix`

| Component | Package |
|-----------|---------|
| LSP | jsonls (vscode-json-languageserver) |
| Tool | jq |
| Plugin | SchemaStore-nvim |

**Features**:
- JSON schema validation
- SchemaStore integration for common schemas
- Completion and formatting

---

### SQL

**File**: `languages/sql.nix`

| Component | Package |
|-----------|---------|
| LSP | sqls |
| Formatter | pgformatter |

**Features**:
- SQL completion and diagnostics
- PostgreSQL-style formatting

---

### Markdown

**File**: `languages/markdown.nix`

| Component | Package |
|-----------|---------|
| LSP | marksman |
| Plugin | render-markdown-nvim |
| Plugin | markdown-preview-nvim |

**Features**:
- Document outline and navigation
- Wiki-link support
- In-buffer markdown rendering
- Browser preview (`<leader>mp`)

---

### Terraform

**File**: `languages/terraform.nix`

| Component | Package |
|-----------|---------|
| LSP | terraformls |
| Tool | terraform |

**Features**:
- HCL completion and validation
- Provider documentation
- Format on save

---

### AWS (CloudFormation)

**File**: `languages/aws.nix`

| Component | Package |
|-----------|---------|
| LSP | yamlls (with CloudFormation schema) |

**Features**:
- CloudFormation template validation
- Intrinsic function support (!Ref, !Sub, etc.)
- SAM template support

---

### Kotlin

**File**: `languages/kotlin.nix`

| Component | Package |
|-----------|---------|
| LSP | kotlin-lsp (JetBrains) |
| Linter | ktlint |
| Tool | gradle |
| Tool | kotlin |

**Features**:
- Official JetBrains Kotlin LSP
- Gradle project support
- IntelliJ-grade code analysis

---

### Scala

**File**: `languages/scala.nix`

| Component | Package |
|-----------|---------|
| LSP | metals |
| Formatter | scalafmt |
| Tool | mill |
| Tool | sbt |
| Plugin | nvim-metals |

**Features**:
- Full Metals language server
- Mill and sbt build support
- Worksheet support
- Ammonite integration

---

### Bash / Shell

**File**: `languages/bash.nix`

| Component | Package |
|-----------|---------|
| LSP | bashls (bash-language-server) |
| Linter | shellcheck |
| Formatter | shfmt |

**Features**:
- Shell script completion and diagnostics
- ShellCheck integration
- Formatting with shfmt

---

### Docker

**File**: `languages/docker.nix`

| Component | Package |
|-----------|---------|
| LSP | dockerls |
| LSP | docker_compose_language_service |
| Linter | hadolint |

**Features**:
- Dockerfile completion and linting
- docker-compose.yml support
- Best practice checks via hadolint

---

## Adding a New Language

### Step 1: Create Module

Create `languages/{lang}.nix`:

```nix
# languages/go.nix
{ pkgs, stablePkgs, ... }:
{
  lspsAndRuntimeDeps = with pkgs; [
    gopls          # LSP
    gofumpt        # Formatter
    golangci-lint  # Linter
    delve          # Debugger
  ];

  startupPlugins = with pkgs.vimPlugins; [
    # go.nvim  # Optional Go plugin
  ];

  optionalPlugins = [ ];

  environmentVariables = {
    # GOPATH = "...";
  };

  extra = {
    # Data for Lua config
  };
}
```

### Step 2: Register Module

Add to `languages/default.nix`:

```nix
availableLanguages = {
  # ... existing ...
  go = ./go.nix;
};
```

### Step 3: Add LSP Configuration

Add to `lua/lua/plugins/lsp.lua`:

```lua
-- Go language support
if hasLang('go') then
  table.insert(servers, 'gopls')
  vim.lsp.config.gopls = {
    capabilities = capabilities,
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
      },
    },
  }
end
```

### Step 4: Add Formatter (Optional)

Add to `lua/lua/plugins/conform.lua`:

```lua
if hasLang('go') then
  formatters_by_ft.go = { 'gofumpt' }
end
```

### Step 5: Add Language-Specific Lua (Optional)

Create `lua/lua/languages/go/go.lua`:

```lua
local nixCats = require('nixCats')

if not nixCats.cats["languages.go"] then
  return
end

-- Go-specific setup
-- require("go").setup({ ... })
```

Register in `lua/lua/languages/init.lua`:

```lua
require('languages.go.go')
```

### Step 6: Test

```bash
# Enable the language in flake.nix or your host config
nix build .#nixcats-full --no-link
nix run .#nixcats-full
```

---

## Language Module Structure

```
nixcats/
├── languages/
│   ├── default.nix      # Module loader
│   ├── nix.nix
│   ├── dotnet.nix
│   ├── rust.nix
│   ├── python.nix
│   ├── typescript.nix
│   ├── json.nix
│   ├── sql.nix
│   ├── markdown.nix
│   ├── terraform.nix
│   ├── aws.nix
│   ├── kotlin.nix
│   ├── scala.nix
│   ├── bash.nix
│   └── docker.nix
└── lua/
    └── lua/
        ├── plugins/
        │   ├── lsp.lua       # LSP configs per language
        │   └── conform.lua   # Formatters per language
        └── languages/
            └── dotnet/       # Language-specific Lua
```
