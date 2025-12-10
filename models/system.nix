{ lib }:
with lib;
let
  constants = import ./constants.nix;
  nospace = str: filter (c: c == " ") (stringToCharacters str) == [ ];
  timezone = types.nullOr (types.addCheck types.str nospace)
    // { description = "null or string without spaces"; };
in
{
  options = {
    nixStateVersion = mkOption {
      type = types.str;
      default = constants.nixStateVersion;
      description = "The nixos state version to use, also used for home-manager";
    };
    darwinStateVersion = mkOption {
      type = types.int;
      default = constants.darwinStateVersion;
      description = "The darwin state version to use";
    };
    timeZone = mkOption {
      default = constants.defaultTimeZone;
      type = timezone;
      example = "America/New_York";
      description = lib.mdDoc ''
        The time zone used when displaying times and dates. See <https://en.wikipedia.org/wiki/List_of_tz_database_time_zones>
        for a comprehensive list of possible values for this setting.

        If null, the timezone will default to UTC and can be set imperatively
        using timedatectl.
      '';
    };
    developerPackages = mkOption {
      type = types.bool;
      default = true;
      description = "Include developer packages like compilers and build tools";
    };
    remoteDevSupport = mkOption {
      type = types.bool;
      default = true;
      description = "Include nix-ld support for remote development and runtime libraries";
    };
    remoteDevSupportExtr = mkOption {
      type = types.listtOf types.package;
      default = [];
      description = "Additional packages to include in the nix-ld remote development support";
    };
  };
}
