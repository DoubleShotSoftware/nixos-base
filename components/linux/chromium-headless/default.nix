# Headless Chromium (remote-debugging/CDP) for MCP/agent dev work, run as a
# home-manager user service.
#
# mTLS: many local backends share https://localhost:8443, so a single URL can't
# pick the right client cert. Each cert is bound to a distinct *.localhost host
# alias (RFC 6761 resolves these to loopback, so Chromium needs no /etc/hosts
# entry, though we add entries for other clients). The app points its apiBaseUrl
# at the alias; the system-wide AutoSelectCertificateForUrls policy then matches
# by hostname and auto-presents the cert. All certs live in one shared NSS DB
# (~/.pki/nssdb), so one Chromium serves every project without per-instance isolation.
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.personalConfig.linux.chromiumHeadless;

  certType = types.submodule ({ config, ... }: {
    options = {
      certPath = mkOption {
        type = types.str;
        description = "PEM client certificate to import (read at runtime, not eval).";
      };
      keyPath = mkOption {
        type = types.str;
        default = (removeSuffix ".crt" config.certPath) + ".key";
        defaultText = literalExpression "<certPath> with .crt replaced by .key";
        description = "PEM private key matching certPath.";
      };
      hostAlias = mkOption {
        type = types.str;
        example = "ftap.localhost";
        description = "Host alias the app must call (e.g. apiBaseUrl). Keys the auto-select policy; use a *.localhost name.";
      };
      apiPort = mkOption {
        type = types.port;
        default = 8443;
        description = "Backend port the alias serves on (the API, not the CDP port).";
      };
      issuerCN = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional issuer CN to tighten the auto-select filter; unset matches any cert acceptable to the server.";
      };
    };
  });

  # Idempotent: refresh ~/.pki/nssdb so a changed cert file is re-imported.
  importScript = pkgs.writeScript "chromium-headless-mtls-import" ''
    #!/usr/bin/env bash
    set -euo pipefail
    db="$HOME/.pki/nssdb"
    ${pkgs.coreutils}/bin/mkdir -p "$db"
    if [ ! -e "$db/cert9.db" ]; then
      ${pkgs.nssTools}/bin/certutil -N -d "sql:$db" --empty-password
    fi
    tmp="$(${pkgs.coreutils}/bin/mktemp -d)"
    trap '${pkgs.coreutils}/bin/rm -rf "$tmp"' EXIT
    import_cert() {
      local cert="$1" key="$2" nick="$3"
      if [ ! -r "$cert" ]; then echo "chromium-headless mtls: cert not found: $cert" >&2; exit 1; fi
      if [ ! -r "$key" ];  then echo "chromium-headless mtls: key not found: $key"  >&2; exit 1; fi
      ${pkgs.openssl}/bin/openssl pkcs12 -export -inkey "$key" -in "$cert" \
        -name "$nick" -passout pass:x -out "$tmp/$nick.p12"
      ${pkgs.nssTools}/bin/certutil -D -d "sql:$db" -n "$nick" >/dev/null 2>&1 || true
      ${pkgs.nssTools}/bin/pk12util -i "$tmp/$nick.p12" -d "sql:$db" -W x >/dev/null
      echo "chromium-headless mtls: imported $nick"
    }
    ${concatMapStringsSep "\n"
      (c: ''import_cert ${escapeShellArg c.certPath} ${escapeShellArg c.keyPath} ${escapeShellArg c.hostAlias}'')
      cfg.mtlsCerts}
  '';

  autoSelect = map (c: builtins.toJSON {
    pattern = "https://${c.hostAlias}:${toString c.apiPort}";
    filter = if c.issuerCN != null then { ISSUER.CN = c.issuerCN; } else { };
  }) cfg.mtlsCerts;

  hostsBlock = concatMapStringsSep "\n"
    (c: "127.0.0.1 ${c.hostAlias}\n::1 ${c.hostAlias}") cfg.mtlsCerts;

  spkiFlag = optionalString (cfg.serverCertSpkiList != [ ])
    " --ignore-certificate-errors-spki-list=${concatStringsSep "," cfg.serverCertSpkiList}";

  userUnits = {
    systemd.user.services.chromium-headless = {
      Unit = {
        Description = "Headless Chromium with remote debugging for MCP dev work";
        Documentation = [ "https://chromedevtools.github.io/devtools-protocol/" ];
      };
      Service = {
        Type = "simple";
        # Profile lives in the runtime dir so it's clean each boot.
        ExecStart = "${pkgs.chromium}/bin/chromium --headless=new --disable-gpu --no-first-run --disable-dev-shm-usage --remote-debugging-address=127.0.0.1 --remote-debugging-port=${toString cfg.port} --user-data-dir=%t/chromium-headless${spkiFlag}";
        Restart = "on-failure";
        RestartSec = "5s";
      } // optionalAttrs (cfg.mtlsCerts != [ ]) {
        ExecStartPre = "${importScript}";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
in {
  options.personalConfig.linux.chromiumHeadless = {
    enable = mkEnableOption "headless Chromium (remote debugging) for MCP/agent dev work";
    users = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Users to run the headless Chromium service for.";
    };
    port = mkOption {
      type = types.port;
      default = 9222;
      description = "CDP remote-debugging port (bound to 127.0.0.1).";
    };
    serverCertSpkiList = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Base64 SHA-256 SPKI hashes of dev server certs whose name/validity errors should be ignored (--ignore-certificate-errors-spki-list). Scoped bypass for alias/self-signed mismatches; leave empty to enforce normally.";
    };
    mtlsCerts = mkOption {
      type = types.listOf certType;
      default = [ ];
      description = "Client certs imported into the shared NSS DB and auto-presented per host alias.";
    };
  };

  config = mkIf cfg.enable {
    # Refuse to fabricate a home-manager profile for a user that isn't a
    # declared account (catches typos in `users`).
    assertions = map (u: {
      assertion = hasAttr u config.users.users;
      message = "personalConfig.linux.chromiumHeadless.users: \"${u}\" is not a configured user (users.users.\"${u}\" is unset).";
    }) cfg.users;

    home-manager.users = genAttrs cfg.users (_user: userUnits);

    # System-wide managed policy: auto-select the alias-bound client cert headlessly
    # (no picker UI). Applies to all chromium on the box, which is what we want here.
    programs.chromium = mkIf (cfg.mtlsCerts != [ ]) {
      enable = true;
      extraOpts.AutoSelectCertificateForUrls = autoSelect;
    };

    networking.extraHosts = mkIf (cfg.mtlsCerts != [ ]) hostsBlock;
  };
}
