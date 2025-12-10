{ lib, pkgs, ... }: {
  opts = {
    enable = true;
    # Rust DAP configuration is managed by rustaceanvim plugin
    # Other language DAP configurations can be added here
  };

  rootOpts = {
    # DAP extensions as separate plugins (they were renamed)
    plugins = {
      dap-ui = {
        enable = true;
        settings.floating.mappings.close = [ "<ESC>" "q" ];
      };
      dap-virtual-text = {
        enable = true;
      };
    };
  };
}
