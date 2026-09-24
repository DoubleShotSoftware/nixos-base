# Generates the LiteLLM-facing parts of opencode's config from litellm's own
# /model/info catalog, so opencode.json never has to be hand-edited when
# models come and go in litellm.nix:
#   provider.<id> : every chat model litellm serves, with context/output caps
#   mcp.<id>      : litellm's aggregated /mcp endpoint (all MCP backends in
#                   one URL, one key) instead of per-backend tokens
#
# How it merges: opencode deep-merges BOTH opencode.json and opencode.jsonc
# from ~/.config/opencode. This sync owns opencode.json exclusively; the
# user's hand-edited opencode.jsonc (watched by opencode-web-reload) is
# never touched. If the jsonc also declares provider.<id>/mcp.<id>, its
# values win the merge — keep those out of the jsonc or this sync is
# decorative.
#
# Key handling: with litellmModels.key set, sops-nix renders the API key to
# keyFile (mode 0600) as a home-manager secret, and the sync service orders
# itself after sops-nix so the first post-boot run sees it. Without it, drop
# a key into keyFile manually. The generated opencode.json embeds the key in
# the MCP Authorization header — it never lands in the Nix store, and the
# file is user-private (umask 077).
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    escapeShellArg
    genAttrs
    makeBinPath
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    types
    ;
  cfg = config.personalConfig.linux.opencode;
  lit = cfg.litellmModels;

  keyAbsPath = config.home.homeDirectory + "/" + lit.keyFile;

  syncScript =
    pkgs.writeScript "opencode-litellm-sync"
    /*
    bash
    */
    ''
      #!/usr/bin/env bash
      set -euo pipefail
      umask 077
      export PATH="${makeBinPath [pkgs.curl pkgs.jq pkgs.coreutils pkgs.systemd]}:$PATH"

      cfgDir="$HOME/.config/opencode"
      outFile="$cfgDir/opencode.json"
      tmp="$cfgDir/.opencode.json.tmp"
      keyFile="$HOME/${lit.keyFile}"
      includeMcp=${
        if lit.mcp.enable
        then "1"
        else "0"
      }

      # No key on this host yet: skip quietly, the timer retries.
      [ -r "$keyFile" ] || exit 0
      key="$(cat "$keyFile")"

      # -f: a down/broken litellm must keep the last good list, not blank it.
      catalog="$(curl -sf --max-time 20 \
        -H "Authorization: Bearer $key" \
        "${lit.url}/model/info")" || exit 0

      # Chat models only — opencode can't consume embeddings, and openrouter/*
      # is a passthrough alias, not an enumerable model. Model keys MUST be
      # the litellm model_names verbatim: the key is the model id litellm
      # receives, including any "[Local] " prefix. limit maps litellm's
      # context/output caps so opencode can warn before oversized prompts.
      provider="$(printf '%s' "$catalog" | jq -c '
        [.data[]
         | select(.model_info.mode == "chat" and .model_name != "openrouter/*")
         | {(.model_name): {
             name: .model_name,
             limit: {
               context: (.model_info.max_input_tokens // 128000),
               output: (.model_info.max_tokens // 16384)
             }
           }
         }]
        | {npm: "@ai-sdk/openai-compatible",
           name: "LiteLLM",
           options: {baseURL: (${escapeShellArg (lit.url + "/v1")})},
           models: (add // {})}')"

      # litellm's /mcp aggregates every MCP backend (metrics, gitea, grafana,
      # tempo, ms-learn) behind one URL and one key.
      mcpJson="null"
      if [ "$includeMcp" -eq 1 ]; then
        mcpJson="$(jq -cn \
          --arg id ${escapeShellArg lit.providerId} \
          --arg url ${escapeShellArg (lit.url + "/mcp")} \
          --arg auth "Bearer $key" \
          '{($id): {
             type: "remote",
             url: $url,
             enabled: true,
             headers: {Authorization: $auth}
           }}')"
      fi

      jq -n --argjson provider "$provider" --argjson mcp "$mcpJson" \
        --arg id ${escapeShellArg lit.providerId} \
        'if $mcp == null
         then {provider: {($id): $provider}}
         else {provider: {($id): $provider}, mcp: $mcp}
         end' > "$tmp"

      # Only rewrite (and bounce opencode-web) when the output changed.
      if [ ! -f "$outFile" ] || ! cmp -s "$tmp" "$outFile"; then
        mv "$tmp" "$outFile"
        systemctl --user try-restart opencode-web.service
      else
        rm -f "$tmp"
      fi
    '';

  # sops ordering only matters when we provision the key ourselves.
  serviceUnit =
    {
      Unit.Description = "Generate opencode LiteLLM provider + MCP config from litellm";
      Service = {
        Type = "oneshot";
        ExecStart = "${syncScript}";
      };
    }
    // (optionalAttrs (lit.key != null) {
      Unit.After = ["sops-nix.service"];
    });

  userUnits =
    {
      systemd.user.services.opencode-litellm-models = serviceUnit;
      systemd.user.timers.opencode-litellm-models = {
        Unit.Description = "Periodically refresh opencode's LiteLLM model list";
        Timer = {
          OnBootSec = "2min";
          OnUnitActiveSec = lit.interval;
          Persistent = true;
        };
        Install.WantedBy = ["timers.target"];
      };
    }
    // (optionalAttrs (lit.key != null) {
      # Rendered to the same path the sync script reads; survives only as
      # long as the session by default — sops-nix hm renders on login.
      sops.secrets."opencode-litellm-key" = {
        sopsFile = lit.key.sopsFile;
        key = lit.key.key;
        path = keyAbsPath;
        mode = "0600";
      };
    });
in {
  options.personalConfig.linux.opencode.litellmModels = {
    enable = mkEnableOption "litellm model-list + MCP sync into opencode's config";

    url = mkOption {
      type = types.str;
      default = "http://172.25.0.5:4000";
      description = "Base URL of the litellm proxy (no /v1 or /mcp suffix).";
    };

    keyFile = mkOption {
      type = types.str;
      default = ".config/opencode/litellm-key";
      description = ''
        File containing a litellm API key (master key or a virtual key),
        relative to the user's home. Provisioned by sops-nix when
        litellmModels.key is set; otherwise place it manually.
      '';
    };

    key = mkOption {
      default = null;
      type = types.nullOr (types.submodule {
        options = {
          sopsFile = mkOption {
            type = types.path;
            description = "SOPS-encrypted file containing the litellm key.";
          };
          key = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Attribute inside sopsFile holding the key (null: whole file is the key).";
          };
        };
      });
      description = "When set, provision keyFile via sops-nix home-manager secrets.";
    };

    mcp = mkOption {
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Also register litellm's aggregated /mcp endpoint in opencode.";
          };
        };
      };
      default = {};
      description = "MCP proxy registration.";
    };

    providerId = mkOption {
      type = types.str;
      default = "litellm";
      description = "opencode id under provider.<id> and mcp.<id> in the generated config.";
    };

    interval = mkOption {
      type = types.str;
      default = "1h";
      description = "systemd timer interval between catalog refreshes.";
    };
  };

  config = mkIf (cfg.enable && lit.enable) {
    home-manager.users = genAttrs cfg.users (_: userUnits);
  };
}
