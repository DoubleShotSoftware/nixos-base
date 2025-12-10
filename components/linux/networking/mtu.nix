{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.personalConfig.networking.mtu;
  
  # Generate route commands for each destination
  mkRoute = dest: ''
    ip route add ${dest.ip}/${toString dest.prefixLength} mtu ${toString dest.mtu} \
      ${concatMapStrings (iface: "dev ${iface} ") dest.interfaces} || true
  '';
  
  # Generate nftables rules for MSS clamping
  mkNftMssRules = ''
    table inet mangle {
      chain forward {
        type filter hook forward priority mangle; policy accept;
        
        # Per-destination MSS clamping
        ${concatMapStrings (dest: 
          if dest.mtu < cfg.default then ''
            ip daddr ${dest.ip}/${toString dest.prefixLength} tcp flags syn tcp option maxseg size set ${toString (dest.mtu - 40)}
          '' else ""
        ) cfg.destinations}
        
        # Fallback: clamp to path MTU for all TCP SYN packets
        tcp flags syn tcp option maxseg size set rt mtu
      }
      
      chain postrouting {
        type filter hook postrouting priority mangle; policy accept;
        
        # Also handle locally generated traffic
        tcp flags syn tcp option maxseg size set rt mtu
      }
    }
  '';
    
in {
  config = mkIf (cfg.destinations != []) {
    # Enable nftables
    networking.nftables.enable = true;
    
    # Enable adaptive PMTU discovery if requested
    boot.kernel.sysctl = mkIf cfg.adaptive {
      "net.ipv4.tcp_mtu_probing" = 2;  # Always probe
      "net.ipv4.tcp_probe_threshold" = 1024;  # Start probing early
      "net.ipv4.tcp_probe_interval" = 600;  # Probe every 10 minutes
      "net.ipv4.tcp_base_mss" = 1024;  # Base MSS for probing
    };
    
    # Apply MTU routes after network is up
    networking.localCommands = ''
      # Wait for network to be ready
      sleep 2
      
      # Add MTU-specific routes
      ${concatMapStrings mkRoute cfg.destinations}
      
      echo "MTU routes configured"
    '';
    
    # Add nftables rules for MSS clamping
    networking.nftables.ruleset = mkNftMssRules;
  };
}