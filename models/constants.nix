{
  # NixOS/Home-manager state version (from branch name 25_05)
  nixStateVersion = "25.05";
  
  # Darwin state version (separate from NixOS)
  darwinStateVersion = 6;
  
  # Supported target systems
  targetSystems = [
    "aarch64-linux"
    "i686-linux" 
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
  
  # Default timezone
  defaultTimeZone = "America/Toronto";
  
  # Default username
  defaultUsername = "sobrien";
}
