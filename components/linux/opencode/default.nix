# opencode (https://opencode.ai) installed per-user via npm into the user's
# ~/.npm-global, run as a home-manager systemd user service:
#   - opencode-web        : the web server (opencode web), restart-on-failure
#   - opencode-update     : daily npm update to @latest, restarts the web server
#   - opencode-web-reload : restarts the web server when opencode.jsonc changes
# Linger is enabled for the chosen users so the server survives logout.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.personalConfig.linux.opencode;

  envExports =
    concatStringsSep "\n"
    (mapAttrsToList (k: v: "export ${k}=${escapeShellArg v}") cfg.environment);

  environmentFiles = map (path: "-%h/${path}") cfg.environmentFiles;

  # install: ensure opencode is present; update: force @latest. Both target the
  # user's ~/.npm-global prefix (same convention as the typescript component).
  npmScript = pkgs.writeScript "opencode-npm" ''
    #!/usr/bin/env bash
    set -euo pipefail
    export npm_config_prefix="$HOME/.npm-global"
    export PATH="${pkgs.nodejs}/bin:$HOME/.npm-global/bin:$PATH"
    ${pkgs.coreutils}/bin/mkdir -p "$npm_config_prefix"
    case "''${1:-install}" in
      install) command -v opencode >/dev/null 2>&1 || npm install -g ${cfg.package}@latest ;;
      update)  npm install -g ${cfg.package}@latest ;;
      *) echo "usage: opencode-npm install|update" >&2; exit 2 ;;
    esac
  '';

  webScript = pkgs.writeScript "opencode-web" ''
    #!/usr/bin/env bash
    set -euo pipefail
    export PATH="$HOME/.npm-global/bin:${pkgs.nodejs}/bin:$PATH"
    ${envExports}
    exec "$HOME/.npm-global/bin/opencode" web --hostname ${cfg.hostname} --port ${toString cfg.port}
  '';

  restartWeb = "${pkgs.systemd}/bin/systemctl --user try-restart opencode-web.service";

  userUnits = {
    systemd.user.services.opencode-web = {
      Unit = {
        Description = "opencode web server";
        Documentation = ["https://opencode.ai"];
      };
      Service = {
        Type = "simple";
        # The leading '-' makes each user-owned file optional. Keep MCP tokens
        # out of the Nix store by placing KEY=value entries in these files.
        EnvironmentFile = environmentFiles;
        # Self-heal: install on first start (and after a failed/absent install),
        # then run the web server. Restart retries the whole chain.
        ExecStartPre = "${npmScript} install";
        ExecStart = "${webScript}";
        Restart = "on-failure";
        RestartSec = "10s";
      };
      Install.WantedBy = ["default.target"];
    };

    systemd.user.services.opencode-update = {
      Unit.Description = "Update opencode to the latest npm release";
      Service = {
        Type = "oneshot";
        ExecStart = "${npmScript} update";
        ExecStartPost = restartWeb;
      };
    };

    systemd.user.timers.opencode-update = {
      Unit.Description = "Daily opencode update check (midnight)";
      Timer = {
        OnCalendar = "*-*-* 00:00:00";
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };

    # A .path unit activates the .service of the same name on change.
    systemd.user.paths.opencode-web-reload = {
      Unit.Description = "Watch opencode.jsonc for changes";
      Path.PathModified = "%h/.config/opencode/opencode.jsonc";
      Install.WantedBy = ["paths.target"];
    };

    systemd.user.services.opencode-web-reload = {
      Unit.Description = "Restart opencode web after config change";
      Service = {
        Type = "oneshot";
        ExecStart = restartWeb;
      };
    };
  };
in {
  options.personalConfig.linux.opencode = {
    enable = mkEnableOption "opencode npm install + web server (per-user, home-manager)";
    users = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Users to install opencode for and run the web server as.";
    };
    package = mkOption {
      type = types.str;
      default = "opencode-ai";
      description = "npm package installed globally into the user's ~/.npm-global.";
    };
    port = mkOption {
      type = types.port;
      default = 4096;
      description = "Port the opencode web server listens on.";
    };
    hostname = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Hostname/IP the opencode web server binds to.";
    };
    environment = mkOption {
      type = types.attrsOf types.str;
      default = {
        OPENCODE_ENABLE_EXA = "1";
        OPENCODE_ENABLE_PARALLEL = "1";
      };
      description = "Environment variables exported for the opencode web server.";
    };
    environmentFiles = mkOption {
      type = types.listOf types.str;
      default = [".config/opencode/environment"];
      description = "Optional environment files, relative to each configured user's home directory, loaded by opencode-web in order.";
    };
  };

  config = mkIf cfg.enable {
    # Refuse to fabricate a home-manager profile for a user that isn't a
    # declared account (catches typos in `users`).
    assertions =
      map (u: {
        assertion = hasAttr u config.users.users;
        message = "personalConfig.linux.opencode.users: \"${u}\" is not a configured user (users.users.\"${u}\" is unset).";
      })
      cfg.users;

    # The web server must outlive interactive logins.
    personalConfig.linux.linger = {
      enable = true;
      users = cfg.users;
    };

    home-manager.users = genAttrs cfg.users (_user: userUnits);
  };
}
