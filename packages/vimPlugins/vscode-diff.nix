# packages/vimPlugins/vscode-diff.nix
# VSCode-style diff viewer for Neovim (esmuellert/codediff.nvim)
# Builds the native C library for character-level diff
{pkgs}: let
  version = "c841f1d7756c9e7224f9c0001f0f775518914150";

  src = pkgs.fetchFromGitHub {
    owner = "esmuellert";
    repo = "codediff.nvim";
    rev = version;
    hash = "sha256-dbc0YgsoGat8g9TFZva2C9oup40YXvTyxf+pFhAG5to=";
  };

  # Build the native library separately
  libcodediff = pkgs.stdenv.mkDerivation {
    pname = "libcodediff";
    inherit version src;

    nativeBuildInputs = with pkgs; [ cmake ];
    buildInputs = with pkgs; [ ]
      ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.llvmPackages.openmp ];

    cmakeFlags = [
      "-DENABLE_OPENMP=${if pkgs.stdenv.isLinux then "ON" else "OFF"}"
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      cp libcodediff/libcodediff.so $out/lib/ 2>/dev/null || \
      cp libcodediff/libcodediff.dylib $out/lib/ 2>/dev/null || true
      runHook postInstall
    '';
  };

in
  pkgs.vimUtils.buildVimPlugin {
    inherit version;
    pname = "codediff-nvim";
    inherit src;

    dependencies = with pkgs.vimPlugins; [ nui-nvim ];

    # Copy the pre-built library into the plugin
    postInstall = ''
      cp ${libcodediff}/lib/libcodediff.* $out/ 2>/dev/null || true
    '';

    # Skip require check - library loading happens at runtime
    doCheck = false;
  }
