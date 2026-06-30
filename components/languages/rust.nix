# Rust language configuration function
{
  pkgs,
  username,
  lib,
  settings ? {},
}: {
  packages = with pkgs; [
    rust-analyzer
    rustc
    rustfmt
    cargo
    clippy
    cargo-watch
    cargo-expand
    cargo-audit
    cargo-outdated
    cargo-edit
    cargo-nextest
    bacon
    just
    gcc
    # clang/llvm share cc/cpp/c++ with gcc; lower their priority so gcc provides
    # the default linker (rust's `cc`) and buildEnv stops colliding on those paths.
    (lib.lowPrio llvm)
    (lib.lowPrio clang)
    stdenv.cc
    vscode-extensions.vadimcn.vscode-lldb.adapter
  ];
  sessionVariables = {
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";
  };
  shellPlugins = {
    zsh = ["rust" "cargo"];
    fish = [];
    bash = [];
  };
  shellInitExtra = {
    zsh = ''
      # Add cargo bin to PATH
      export PATH="$CARGO_HOME/bin:$PATH"
    '';
    fish = ''
      # Add cargo bin to PATH
      fish_add_path $CARGO_HOME/bin
    '';
    bash = ''
      # Add cargo bin to PATH
      export PATH="$CARGO_HOME/bin:$PATH"
    '';
  };
  permittedInsecurePackages = [];
}
