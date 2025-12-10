# Shell Configuration System Improvements

This document outlines potential improvements and fixes for the shell configuration system in nixos-base.

## 1. Deprecate Legacy `zsh.enable` Option

**Priority: High**

Currently, there's both `shell = "zsh"` and the legacy `zsh.enable` option. We should:

- Mark `zsh.enable` as deprecated in the user model
- Add a migration warning when `zsh.enable` is true but `shell` isn't set to "zsh" 
- Eventually remove the `zsh.enable` option entirely

**Implementation:**
```nix
# In models/user.nix
zsh = {
  enable = mkOption {
    type = types.bool;
    description = "DEPRECATED: Use shell = \"zsh\" instead. Whether to enable zsh for user.";
    default = false;
  };
};
```

## 2. Shell Injector Improvements

**Priority: High**

The current shell injector has some limitations:

### macOS Support
The `ps` command syntax in the injection script may not work on macOS. We should use a more portable approach:

```bash
# Instead of: $(ps --no-header --pid=$PPID --format=comm)
# Use: $(ps -o comm= -p $PPID 2>/dev/null)
```

### Better Shell Detection
Instead of checking `$PPID`, we could check `$SHLVL` more intelligently

### User Feedback
Add comments in the generated `.bashrc`/`.zshrc` files explaining what they do

## 3. Module Organization

**Priority: Medium**

- **Create a shells directory**: Move both `zsh` and `fish` modules into `home-manager/shells/` for better organization
- **Consolidate shell logic**: Create a shared shell utilities module to reduce duplication between fish and zsh

```
home-manager/
├── shells/
│   ├── default.nix          # Common shell utilities
│   ├── zsh/
│   │   └── default.nix
│   └── fish/
│       └── default.nix
└── shell-injector/
    └── default.nix
```

## 4. Error Handling

**Priority: Medium**

- Add assertions to ensure `shellInjector` value matches a valid shell
- Validate that if `shellInjector` is set, the corresponding shell package is available
- Better error messages when shell configuration conflicts occur

**Implementation:**
```nix
assertions = [
  {
    assertion = userConfig.shellInjector == "disabled" || 
                 builtins.elem userConfig.shellInjector ["bash" "zsh" "fish"];
    message = "shellInjector must be one of: disabled, bash, zsh, fish";
  }
];
```

## 5. Documentation

**Priority: Medium**

- Add comments explaining the relationship between `shell` and `shellInjector`
- Document when to use each option
- Create examples for common scenarios

### Usage Examples:

```nix
# NixOS system - shell is set at system level
users.sobrien = {
  shell = "zsh";
  shellInjector = "disabled";  # Not needed on NixOS
};

# macOS/non-NixOS - use injector
users.sobrien = {
  shell = "zsh";               # Configures zsh in home-manager
  shellInjector = "zsh";       # Creates .bashrc that execs zsh
};
```

## 6. Platform-Specific Improvements

**Priority: Medium**

### WSL Detection
The fish module has WSL-specific aliases that should only apply on WSL:

```nix
shellAliases = lib.optionalAttrs isWSL {
  pbcopy = "/mnt/c/Windows/System32/clip.exe";
  pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
  explorer = "/mnt/c/Windows/explorer.exe";
};
```

### macOS paths
The hardcoded `/opt/homebrew/bin` should check if it exists first:

```nix
home.sessionPath = mkIf (pkgs.stdenv.isDarwin && builtins.pathExists /opt/homebrew/bin) 
  [ "/opt/homebrew/bin/" ];
```

### Linux paths
The XDG_DATA_DIRS flatpak paths should be conditional on flatpak being installed

## 7. Shell Injector Edge Cases

**Priority: Low**

- Handle the case where user's default shell is already the target shell
- Support for other common shells (e.g., if system uses `dash` or `sh`)
- Handle non-interactive shells better

## 8. Testing Helpers

**Priority: Low**

Add a `personalConfig.users.<name>.testShellInjection` option that:
- Generates test scripts to verify injection works
- Provides dry-run capability  
- Shows what files would be created

## 9. Clean up Unused Variables

**Priority: Low**

- Remove `zshEnabled` variable in `components/general/default.nix` (line 6)
- Clean up any other legacy code references

## 10. Improve Shell Package Detection

**Priority: Low**

Instead of hardcoding shell paths, use:

```nix
shellPaths = {
  bash = lib.getExe pkgs.bash;
  zsh = lib.getExe pkgs.zsh; 
  fish = lib.getExe pkgs.fish;
};
```

## Implementation Priority

1. **Critical**: Fix macOS compatibility in shell injector script
2. **Important**: Deprecate `zsh.enable` with proper warnings
3. **Nice to have**: Reorganize modules and add documentation

## Migration Guide

When implementing these changes:

1. Add deprecation warnings first
2. Maintain backward compatibility during transition
3. Update documentation and examples
4. Test on multiple platforms (NixOS, macOS, non-NixOS Linux)
5. Remove deprecated options in next major version