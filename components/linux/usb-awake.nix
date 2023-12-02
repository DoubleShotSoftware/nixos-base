{ config, lib, options, pkgs, ... }:
with lib;
with builtins;
let
  usbAwakeOptions = { ... }: {
    options = {
      idVendor = mkOption {
        type = types.str;
        description = "Vendor id of usb device";
        example = "lan";
      };
      idProduct = mkOption {
        type = types.str;
        description = "Product id of usb device.";
      };
    };
  };
  buildRule = device: "ACTION==\"add\", SUBSYSTEM==\"usb\", ATTR{idVendor}==\"${device.idVendor}\", ATTR{idProduct}==\"${device.idProduct}\",  ATTR{power/autosuspend}=\"500\", ATTR{power/autosuspend}=\"500000\"";
  newRules =  map (device: (buildRule device)) config.personalConfig.linux.usbAwake;
in {
  options.personalConfig.linux.usbAwake = mkOption {
    type = types.listOf (types.submodule usbAwakeOptions);
    default = [ ];
  };
  config = {
      services.udev.extraRules =  (lib.concatStringsSep "\n" newRules);
  };
}

