# nixos-base

Shared NixOS, nix-darwin, and Home Manager modules, overlays, and development packages for personal host configurations.

## Exports

- `nixosModules`: `Models`, `Common`, `Linux`, `MacOs`, `HomeManager`, `Languages`, and `CommonWithOverlay`.
- `homeManagerModules`: `default`, `languages`, and `withOverlay`.
- `packages`: NixCats variants and `resharper-cli`, `easy-dotnet-tool`, and `roslyn-language-server`.
- `overlays.default`: supplies `unstable`, `dotnetSDK`, Kotlin support, custom Vim plugins, `mkNixCatsIDE`, and the custom packages.
- `lib.mkNixCats`: builds a NixCats package for a selected system and language list.

Check the flake:

```bash
nix flake check
```

**Run NixCats**

```bash
nix run 'github:DoubleShotSoftware/nixos-base?ref=25_11#nixcats-dotnet'
```

_dotnet_ can be one of the supported languages

## Docs

- [NixCats and Neovim](docs/nvim/README.md)
