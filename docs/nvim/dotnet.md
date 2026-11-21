# .NET and C#

The `nixcats-dotnet` package bundles the repository's combined .NET SDK, a pinned `dotnet-easydotnet` server matched to the EasyDotnet plugin, CSharpier, `netcoredbg`, `dotnet-outdated`, NuGet, and `dotnet-ef`. EasyDotnet provides the built-in Roslyn LSP, build and test commands, and debugging; DAP support is enabled and can load `.vscode/launch.json` for C#.

The pinned server is moved ahead of host paths so an auto-updated `~/.dotnet/tools` EasyDotnet installation cannot override it. C# formatting uses CSharpier.

## Commands and Keys

These mappings are buffer-local for `cs`, `csproj`, `fsproj`, and `sln` files:

| Key | Command |
| --- | --- |
| `<leader>lbe` | Open `:Dotnet` commands |
| `<leader>lbb` | Build to quickfix |
| `<leader>lbr` | Restore |
| `<leader>lbc` | Clean |
| `<leader>lbt` | Open the test runner |
| `<leader>lbd` | Debug; loads `.vscode/launch.json` when present |

`<leader>` is Space. See [keybindings](keybindings.md) for shared LSP and formatting mappings.

## LSP Checks

Use `<leader>li` or `:checkhealth lsp` to inspect LSP health. Use `:LspLog` to open the LSP log when diagnosing a handshake or server issue.

Run `dotnet --info` from the project directory to see the discovered `global.json`. A project needs a valid `global.json` for the SDK selection it requires.

## Upstream

- [easy-dotnet.nvim](https://github.com/GustavEikaas/easy-dotnet.nvim)
- [Roslyn](https://github.com/dotnet/roslyn)
- [CSharpier](https://csharpier.com/)
- [netcoredbg](https://github.com/Samsung/netcoredbg)
