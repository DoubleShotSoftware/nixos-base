# packages/vimPlugins/vscode-diff.nix
# VSCode-style diff viewer for Neovim (esmuellert/codediff.nvim)
# Builds the native C library for character-level diff
{pkgs}: let
  version = "832f1ecc5f8b15a44cf7537e31d3266d657775b1";

  src = pkgs.fetchFromGitHub {
    owner = "esmuellert";
    repo = "codediff.nvim";
    rev = version;
    hash = "sha256-iiDf5rbRHJePlv8kBtAID8qVGNBCKi1iipQ9nmMXI18=";
  };

  # Build the native library separately
  libvscode-diff = pkgs.stdenv.mkDerivation {
    pname = "libvscode-diff";
    inherit version src;

    nativeBuildInputs = with pkgs; [ cmake ];
    buildInputs = with pkgs; [ ]
      ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.llvmPackages.openmp ];

    cmakeFlags = [
      "-DENABLE_OPENMP=${if pkgs.stdenv.isLinux then "ON" else "OFF"}"
    ];

    # Library is built in libvscode-diff/ subdirectory as libvscode_diff.so
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      cp libvscode-diff/libvscode_diff.so $out/lib/ 2>/dev/null || \
      cp libvscode-diff/libvscode_diff.dylib $out/lib/ 2>/dev/null || true
      runHook postInstall
    '';
  };

in
  pkgs.vimUtils.buildVimPlugin {
    inherit version;
    pname = "codediff-nvim";
    inherit src;

    dependencies = [];

    # Copy the pre-built library and libgomp into the plugin root
    # The unversioned name (libvscode_diff.so) tells installer.needs_update() to skip auto-install
    # Bundling libgomp.so.1 prevents the installer from trying to download it on Nix systems
    postInstall = ''
      cp ${libvscode-diff}/lib/libvscode_diff.* $out/ 2>/dev/null || true
      ${pkgs.lib.optionalString pkgs.stdenv.isLinux ''
        cp ${pkgs.llvmPackages.openmp}/lib/libomp.so $out/libgomp.so.1 2>/dev/null || true
      ''}
    '';

    # Skip require check - library loading happens at runtime
    doCheck = false;
  }
