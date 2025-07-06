{pkgs, ...}: {
  programs = {
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
    lsd = {
      enable = true;
      enableAliases = true;
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = ["--cmd cd"];
    };
    broot = {
      enable = true;
      enableFishIntegration = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
