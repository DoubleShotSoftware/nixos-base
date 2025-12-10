{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  cfg = config.personalConfig.linux.ssh-agent;

  # Create SSH rc script for each user
  mkSshRc = user: pkgs.writeText "ssh-rc-${user}" ''
    #!/bin/sh
    # SSH rc script to set up SSH_AUTH_SOCK for incoming SSH sessions

    # Try to find and export SSH auth socket
    if [ -S "$XDG_RUNTIME_DIR/ssh-agent.socket" ]; then
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    elif [ -S "$XDG_RUNTIME_DIR/keyring/ssh" ]; then
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
    elif [ -S "/run/user/$(id -u)/ssh-agent.socket" ]; then
        export SSH_AUTH_SOCK="/run/user/$(id -u)/ssh-agent.socket"
    elif [ -S "/run/user/$(id -u)/keyring/ssh" ]; then
        export SSH_AUTH_SOCK="/run/user/$(id -u)/keyring/ssh"
    fi

    # Export to systemd user environment if available
    if [ -n "$SSH_AUTH_SOCK" ] && command -v systemctl >/dev/null 2>&1; then
        systemctl --user import-environment SSH_AUTH_SOCK 2>/dev/null || true
    fi

    # Source the real SSH rc if it exists (renamed to rc.real)
    if [ -f "$HOME/.ssh/rc.real" ]; then
        . "$HOME/.ssh/rc.real"
    fi
  '';

  # Environment setup script
  sshAgentEnv = pkgs.writeText "ssh-agent-env.sh" ''
    # SSH Agent Environment Setup
    # This file is sourced by /etc/profile.d/

    # Function to find and export SSH auth socket
    setup_ssh_auth_sock() {
        local uid=$(id -u)
        local runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$uid}"

        # Check for sockets in order of preference
        if [ -S "$runtime_dir/ssh-agent.socket" ]; then
            export SSH_AUTH_SOCK="$runtime_dir/ssh-agent.socket"
        elif [ -S "$runtime_dir/keyring/ssh" ]; then
            export SSH_AUTH_SOCK="$runtime_dir/keyring/ssh"
        fi

        # Set SSH askpass if using gnome-keyring
        if [ -n "$SSH_AUTH_SOCK" ] && [[ "$SSH_AUTH_SOCK" == *"keyring"* ]]; then
            export SSH_ASKPASS="${pkgs.seahorse}/libexec/seahorse/ssh-askpass"
            export SSH_ASKPASS_REQUIRE=prefer
        fi
    }

    # Run setup if we're in an interactive shell
    if [[ $- == *i* ]] || [ -n "$SSH_CONNECTION" ]; then
        setup_ssh_auth_sock
    fi
  '';
in
{
  options.personalConfig.linux.ssh-agent = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable persistent SSH agent support with systemd user services.";
    };

    type = mkOption {
      type = types.enum [ "openssh" "gnome-keyring" ];
      default = "gnome-keyring";
      description = "Type of SSH agent to use (openssh or gnome-keyring).";
    };

    persistSocket = mkOption {
      type = types.bool;
      default = true;
      description = "Enable persistent socket via systemd linger.";
    };

    users = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of users to enable SSH agent for.";
    };

    socketPath = mkOption {
      type = types.str;
      default = "%t/ssh-agent.socket";
      description = "Path to SSH agent socket (%t expands to XDG_RUNTIME_DIR).";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Common configuration for all SSH agent types
    {
      # Enable linger for persistent sockets if requested
      personalConfig.linux.linger = mkIf cfg.persistSocket {
        enable = true;
        users = cfg.users;
      };

      # Install SSH agent environment script
      environment.etc."profile.d/ssh-agent-env.sh" = {
        source = sshAgentEnv;
        mode = "0644";
      };

      # System packages
      environment.systemPackages = with pkgs; [
        openssh
      ] ++ optionals (cfg.type == "gnome-keyring") [
        gnome-keyring
        seahorse
      ];
    }

    # OpenSSH Agent Configuration
    (mkIf (cfg.type == "openssh") {
      # Create systemd user service for each user
      systemd.user.services.ssh-agent = {
        description = "OpenSSH Agent";
        documentation = [ "man:ssh-agent(1)" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent.socket";
          ExecStartPost = "${pkgs.coreutils}/bin/chmod 600 %t/ssh-agent.socket";
          Restart = "on-failure";
          RestartSec = "5s";
          StandardOutput = "journal";
          StandardError = "journal";

          # Security settings
          PrivateTmp = true;
          NoNewPrivileges = true;
          ProtectSystem = "strict";
          ProtectHome = "read-only";
          ReadWritePaths = "%t";
        };

        wantedBy = [ "default.target" ];

        environment = {
          SSH_AUTH_SOCK = "%t/ssh-agent.socket";
        };
      };

      # SSH client configuration
      programs.ssh.startAgent = false; # We manage it ourselves
      programs.ssh.extraConfig = ''
        # Use our persistent SSH agent socket
        Host *
          AddKeysToAgent yes
      '';
    })

    # GNOME Keyring SSH Agent Configuration
    (mkIf (cfg.type == "gnome-keyring") {
      # Enable GNOME keyring service
      services.gnome.gnome-keyring.enable = true;

      # PAM configuration to unlock keyring on login
      security.pam.services = {
        login.enableGnomeKeyring = true;
        sddm.enableGnomeKeyring = true;
        gdm.enableGnomeKeyring = true;
        lightdm.enableGnomeKeyring = true;
      };

      # Create systemd user service for GNOME keyring
      systemd.user.services.gnome-keyring-ssh = {
        description = "GNOME Keyring SSH Agent";
        documentation = [ "man:gnome-keyring-daemon(1)" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = pkgs.writeShellScript "start-gnome-keyring-ssh" ''
            # Kill any existing gnome-keyring daemon
            ${pkgs.procps}/bin/pkill -f "gnome-keyring-daemon" || true

            # Start gnome-keyring with SSH component
            exec ${pkgs.gnome-keyring}/bin/gnome-keyring-daemon \
              --foreground \
              --components=ssh \
              --control-directory=%t/keyring
          '';
          Restart = "on-failure";
          RestartSec = "5s";
          StandardOutput = "journal";
          StandardError = "journal";
        };

        wantedBy = [ "default.target" ];
        after = [ "dbus.service" ];

        environment = {
          DISPLAY = ":0"; # May be needed for some operations
          DBUS_SESSION_BUS_ADDRESS = "unix:path=%t/bus";
        };
      };
    })

    # Per-user configuration via home-manager
    {
      home-manager.users = mkMerge (map (user: {
        "${user}" = { pkgs, ... }: {
          # Create .ssh/rc for SSH session setup
          home.file.".ssh/rc" = {
            enable = true;
            executable = true;
            source = mkSshRc user;
          };

          # Shell-specific configuration
          programs.bash.initExtra = mkIf cfg.enable ''
            # SSH Agent setup for bash
            setup_ssh_auth_sock() {
                local runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

                if [ -S "$runtime_dir/ssh-agent.socket" ]; then
                    export SSH_AUTH_SOCK="$runtime_dir/ssh-agent.socket"
                elif [ -S "$runtime_dir/keyring/ssh" ]; then
                    export SSH_AUTH_SOCK="$runtime_dir/keyring/ssh"
                fi

                # Set SSH askpass for gnome-keyring
                if [[ "$SSH_AUTH_SOCK" == *"keyring"* ]]; then
                    export SSH_ASKPASS="${pkgs.seahorse}/libexec/seahorse/ssh-askpass"
                    export SSH_ASKPASS_REQUIRE=prefer
                fi
            }
            setup_ssh_auth_sock
          '';

          programs.fish.interactiveShellInit = mkIf cfg.enable ''
            # SSH Agent setup for fish
            function setup_ssh_auth_sock
                set -l runtime_dir "$XDG_RUNTIME_DIR"
                test -z "$runtime_dir"; and set runtime_dir "/run/user/"(id -u)

                if test -S "$runtime_dir/ssh-agent.socket"
                    set -gx SSH_AUTH_SOCK "$runtime_dir/ssh-agent.socket"
                else if test -S "$runtime_dir/keyring/ssh"
                    set -gx SSH_AUTH_SOCK "$runtime_dir/keyring/ssh"
                end

                # Set SSH askpass for gnome-keyring
                if string match -q "*keyring*" "$SSH_AUTH_SOCK"
                    set -gx SSH_ASKPASS "${pkgs.seahorse}/libexec/seahorse/ssh-askpass"
                    set -gx SSH_ASKPASS_REQUIRE prefer
                end
            end
            setup_ssh_auth_sock
          '';

          programs.zsh.initExtra = mkIf cfg.enable ''
            # SSH Agent setup for zsh
            setup_ssh_auth_sock() {
                local runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

                if [ -S "$runtime_dir/ssh-agent.socket" ]; then
                    export SSH_AUTH_SOCK="$runtime_dir/ssh-agent.socket"
                elif [ -S "$runtime_dir/keyring/ssh" ]; then
                    export SSH_AUTH_SOCK="$runtime_dir/keyring/ssh"
                fi

                # Set SSH askpass for gnome-keyring
                if [[ "$SSH_AUTH_SOCK" == *"keyring"* ]]; then
                    export SSH_ASKPASS="${pkgs.seahorse}/libexec/seahorse/ssh-askpass"
                    export SSH_ASKPASS_REQUIRE=prefer
                fi
            }
            setup_ssh_auth_sock
          '';

          # Add SSH configuration
          programs.ssh = {
            enable = true;
            extraConfig = ''
              # Ensure we use the persistent agent
              AddKeysToAgent yes

              # Forward agent for remote connections
              ForwardAgent yes
            '';
          };
        };
      }) cfg.users);
    }
  ]);
}
