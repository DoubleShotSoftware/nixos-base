{
  pkgs,
  config,
  ...
}: let
  cfg = config.homeConfig;
in {
  programs = {
    git = {
      enable = true;
      package = pkgs.unstable.git;
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
      # userName and userEmail are now configured via personalConfig.users.<name>.git
      extraConfig = {
        credential = {
          helper = "cache --timeout=86400";
        };
        http = {postBuffer = 524288000;};
        lfs = {
          enable = true;
        };
      };
      lfs = {
        enable = true;
      };
    };
  };
}
