{ icons, pkgs, ... }:

{
  opts = {
    enable = true;
    inlayHints = true;
    keymaps = {
      extra = [
        {
          mode = "n";
          key = "<leader>li";
          action = "<cmd>LspInfo<cr>";
          options.desc = "Show LSP info";
        }
        {
          mode = "n";
          key = "<leader>lh";
          action = "<cmd>checkhealth<cr>";
          options.desc = "Show LSP info";
        }
        {
          mode = "n";
          key = "<leader>ll";
          action.__raw = "function() vim.lsp.codelens.refresh() end";
          options.desc = "LSP CodeLens refresh";
        }
        {
          mode = "n";
          key = "gl";
          action.__raw = "function() vim.lsp.buf.signature_help() end";
          options.desc = "Show signature help";
        }
        {
          mode = "n";
          key = "<leader>lL";
          action.__raw = "function() vim.lsp.codelens.run() end";
          options.desc = "LSP CodeLens run";
        }
        {
          mode = "n";
          key = "<leader>lh";
          action.__raw = "function() vim.lsp.codelens.run() end";
          options.desc = "LSP Toggle Inlay Hints";
        }
      ];

      lspBuf = {
        "<leader>la" = {
          action = "code_action";
          desc = "LSP code action";
        };

        gd = {
          action = "definition";
          desc = "Go to definition";
        };

        gI = {
          action = "implementation";
          desc = "Go to implementation";
        };

        gy = {
          action = "type_definition";
          desc = "Go to type definition";
        };
        K = {
          action = "hover";
          desc = "LSP hover";
        };
      };
    };

    postConfig = ''
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
        vim.lsp.inlay_hint.enable(true, {})

        vim.diagnostic.config({
          virtual_text = true,
          signs = true,
          underline = true,
          update_in_insert = true,
          severity_sort = false,
        })

        local signs = {
          Error = "${icons.DiagnosticError}",
          Warn = "${icons.DiagnosticWarn}",
          Info = "${icons.DiagnosticInfo}",
          Hint = "${icons.DiagnosticHint}",
        }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
      ${builtins.readFile ../lua/lsp_cmds.lua}
    '';

    # Load all servers definitions
    servers = {
      bashls.enable = true;
      docker_compose_language_service.enable = true;
      dockerls.enable = true;
      eslint.enable = true;
      html.enable = true;
      jsonls.enable = true;
      lua_ls.enable = true;
      nginx_language_server.enable = true;
      marksman.enable = true;
      yamlls.enable = true;
      nil_ls.enable = true;
      nixd.enable = true;
      pyright.enable = true;
      sqls.enable = true;
      ts_ls.enable = true;
      # nbypos_lsp = {
      #   enable = true;
      #   extraOptions.init_options.diagnosticSeverity = "Hint";
      # };
    };
  };

  rootOpts = {
    colorschemes.catppuccin.settings.integrations.native_lsp.enabled = true;
    extraPackages = with pkgs; [
      csharpier
      pgformatter
      python312Packages.sqlfmt
      prettierd
      shfmt
      alejandra
      mdformat
      jq
    ];
  };
}
