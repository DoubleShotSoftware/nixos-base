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
    # gcc and clang wrappers both default to priority 10 and share cc/cpp/c++;
    # hiPrio gcc so it wins those paths (rust's default `cc` linker) and buildEnv
    # stops colliding. clang/llvm stay available for libclang-based crates.
    (lib.hiPrio gcc)
    llvm
    clang
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
