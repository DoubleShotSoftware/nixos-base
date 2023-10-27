{ config, lib, options, pkgs, ... }: {

  options.personalConfig.system.yubiKey = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable YubiKey support
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.personalConfig.system.yubiKey.enable {
      services.udev.packages = [ pkgs.yubikey-personalization ];

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryFlavor = "gtk2";
      };
    })
  ];
}
