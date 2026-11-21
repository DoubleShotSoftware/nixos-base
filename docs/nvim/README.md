# NixCats Neovim

NixCats packages provide Neovim with the selected language tooling. See [.NET and C#](dotnet.md), [keybindings](keybindings.md), and [Git integration](git.md).

## Variants

- `nixcats`: Nix tooling.
- `nixcats-full`: Nix plus every configured language category.
- `nixcats-dev`: Nix tooling without the wrapped configuration.
- `nixcats-{nix,dotnet,rust,python,typescript,json,sql,terraform,aws,kotlin}`: Nix plus one language category.

## Run

Run a local package:

```bash
nix run .#nixcats-dotnet
```

Run the repository branch without a checkout:

```bash
nix run 'github:DoubleShotSoftware/nixos-base?ref=25_11#nixcats-dotnet'
```

Use a full commit SHA for an immutable reference:

```bash
nix run 'github:DoubleShotSoftware/nixos-base/<commit>#nixcats-dotnet'
```

Pass a file or solution to Neovim after `--`:

```bash
nix run .#nixcats-dotnet -- path/to/project.sln
```

`nix run` supplies the editor and its toolchain. It does not supply project source, private NuGet credentials, secrets, or runtime services.

See the [repository overview](../../README.md).

## Upstream

- [Neovim](https://neovim.io/)
- [nixCats](https://github.com/BirdeeHub/nixCats-nvim)
- [Nix](https://nixos.org/)
