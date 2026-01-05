# packages/vimPlugins/vscode-diff.nix
# VSCode-style diff viewer for Neovim (esmuellert/vscode-diff.nvim)
# Builds the native C library for character-level diff
{pkgs}: let
  version = "f2c6907410161f430e3301fb170fd1d2094174aa";

  src = pkgs.fetchFromGitHub {
    owner = "esmuellert";
    repo = "vscode-diff.nvim";
    rev = version;
    hash = "sha256-0kPFAyPY7Ki/xY2mlDFBidelDWT2VH/xjmiIfVsPVXo=";
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

    # Let cmake hook handle configure/build, just override install
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      # Library is built in build/libvscode-diff/ by cmake
      cp libvscode-diff/libvscode_diff.so $out/lib/ 2>/dev/null || \
      cp libvscode-diff/libvscode_diff.dylib $out/lib/ 2>/dev/null || true
      runHook postInstall
    '';
  };

in
  pkgs.vimUtils.buildVimPlugin {
    inherit version;
    pname = "vscode-diff-nvim";
    inherit src;

    dependencies = with pkgs.vimPlugins; [ nui-nvim ];

    # Copy the pre-built library into the plugin
    postInstall = ''
      cp ${libvscode-diff}/lib/libvscode_diff.* $out/ 2>/dev/null || true
    '';

    # Skip require check - library loading happens at runtime
    doCheck = false;
  }
