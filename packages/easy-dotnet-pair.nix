# packages/easy-dotnet-pair.nix
# Single source of truth for the easy-dotnet plugin <-> server pairing.
#
# The easy-dotnet.nvim plugin (packages/vimPlugins/easy-dotnet.nix) and the
# EasyDotnet dotnet global tool (packages/easy-dotnet-tool.nix) are
# protocol-coupled: the plugin only speaks the RPC routes of a server version
# it was tested against. Both derivations read their pins from HERE, so bumping
# the pair means editing this one file — nothing else can drift independently.
#
# To bump:
#   1. Update pluginRev/pluginHash AND serverVersion/serverHash together.
#   2. Verify the new combo (e.g. `nix build .#nixcats-dotnet` + a smoke test
#      in a real solution).
#   3. Add the combo to `knownPairs` below.
#
# The build FAILS (both derivations assert) whenever the active pair is not
# listed in `knownPairs`, so an unpinned or half-bumped combo can never build.
let
  # Tested plugin-rev <-> server-version combos, newest first. A combo only
  # enters this list after it has been verified. Keeping every tested combo
  # (not just the current one) catches reverts of one side while the other
  # stays on a newer value.
  knownPairs = [
    {
      pluginRev = "aa9c65fb34ec6f86cf8174eac69a8a217cc7c47e";
      serverVersion = "3.4.14";
    }
  ];

  # The currently pinned plugin commit.
  pluginRev = "aa9c65fb34ec6f86cf8174eac69a8a217cc7c47e";
  pluginHash = "sha256-H1ixoW/2RnK/TPy+rexpyaSGGNNotq/d3RaRMirUqIg=";

  # The currently pinned server version.
  serverVersion = "3.4.14";
  serverHash = "sha256-a1ZBCZZyvyQvlXmhxnMgeslzgEq9Pk4q9+1gojtJ9XE=";

  # True when the active (pluginRev, serverVersion) pair appears verbatim in
  # knownPairs. Both sides must match an entry, so bumping only one half fails.
  isCurrentPairRegistered = builtins.any (p:
    p.pluginRev == pluginRev
    && p.serverVersion == serverVersion
  ) knownPairs;
in {
  inherit knownPairs pluginRev pluginHash serverVersion serverHash isCurrentPairRegistered;
}
