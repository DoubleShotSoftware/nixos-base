{ pkgs, ... }:
{
  opts = {
    enable = true;

    settings = {
      # Tools configuration
      tools = {
        # Use cargo-nextest for running tests (auto-detected)
        enable_nextest = true;

        # Enable clippy checks on save
        enable_clippy = true;

        # Replace Neovim's built-in hover with rust-analyzer's hover actions
        hover_actions = {
          replace_builtin_hover = true;
        };

        # Executor for runnables (cargo run, cargo test, etc.)
        # Options: "termopen", "toggleterm", "quickfix", "vimux"
        executor = "termopen";

        # Reload workspace when Cargo.toml changes
        reload_workspace_from_cargo_toml = true;
      };

      # LSP server configuration
      server = {
        # Auto-attach to Rust buffers
        standalone = true;

        # rust-analyzer settings
        default_settings = {
          rust-analyzer = {
            # Cargo configuration
            cargo = {
              # Enable build scripts
              buildScripts.enable = true;

              # Build all targets (bins, tests, benches, examples)
              allTargets = true;

              # Enable all features
              features = "all";
            };

            # Use clippy instead of cargo check
            check = {
              command = "clippy";
              allTargets = true;
            };

            # Proc macro support
            procMacro = {
              enable = true;
              attributes.enable = true;
            };

            # Inlay hints configuration
            inlayHints = {
              # Show binding mode hints (ref, mut, etc.)
              bindingModeHints.enable = true;

              # Show closure return type hints
              closureReturnTypeHints.enable = "always";

              # Show lifetime elision hints
              lifetimeElisionHints.enable = "always";

              # Show parameter name hints
              parameterHints.enable = true;

              # Show type hints for variables
              typeHints.enable = true;
            };

            # Diagnostics
            diagnostics = {
              enable = true;
              experimental.enable = true;
            };

            # Hover actions
            hover = {
              actions.enable = true;
            };
          };
        };
      };

      # DAP (Debug Adapter Protocol) configuration
      dap = {
        # Automatically load DAP configurations when rust-analyzer attaches
        autoload_configurations = true;

        # CodeLLDB adapter configuration
        adapter = {
          type = "server";
          host = "127.0.0.1";
          port = "13000";
          executable = {
            command = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
            args = [
              "--port"
              "13000"
            ];
          };
        };
      };
    };
  };
}
