# Example test VM configuration
# Shows how to build a VM using the factory base
{ config, lib, pkgs, ... }:
{
  imports = [
    ../base.nix
  ];
  
  # VM-specific configuration
  vm.config = {
    enable = true;
    method = "embedded";
    hostname = "test-vm-01"; 
    repo = "https://github.com/example/vm-configs";
    branch = "main";
  };
  
  # Test-specific overrides
  networking.hostName = "factory-test-01";
  
  # Add any test-specific services
  services.nginx = {
    enable = true;
    virtualHosts."test.local" = {
      root = "/var/www/test";
    };
  };
  
  # Create test content
  systemd.tmpfiles.rules = [
    "d /var/www/test 0755 root root -"
    "f /var/www/test/index.html 0644 root root - <h1>Factory Test VM</h1>"
  ];
}