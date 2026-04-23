# packages/kotlin-lsp.nix
# JetBrains Kotlin Language Server
{ pkgs, lib, stdenv, fetchurl, makeWrapper, jdk17 }:

let
  version = "262.2310.0";
  platform = if stdenv.isDarwin then "macos-aarch64" else "linux-x64";
in
stdenv.mkDerivation {
  pname = "kotlin-lsp";
  inherit version;

  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/kotlin-lsp/${version}/kotlin-lsp-${version}-${platform}.zip";
    hash = "sha256-wAQkIVj0teHZF93YSOb2onlIT6WKPivOiEa4B9GtFrE=";
  };

  nativeBuildInputs = [ pkgs.unzip makeWrapper ];
  buildInputs = [ jdk17 ];

  unpackPhase = ''
    unzip $src -d extracted
  '';

  installPhase = ''
    mkdir -p $out/lib/kotlin-lsp $out/bin

    # Copy the extracted contents
    cp -r extracted/kotlin-lsp-${version}/* $out/lib/kotlin-lsp/

    # Create a stable CLI wrapper around the upstream launcher.
    makeWrapper $out/lib/kotlin-lsp/bin/intellij-server $out/bin/kotlin-lsp \
      --prefix PATH : ${lib.makeBinPath [ jdk17 ]}
  '';

  meta = with lib; {
    description = "Official Language Server for Kotlin from JetBrains";
    homepage = "https://github.com/Kotlin/kotlin-lsp";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-darwin" ];
    mainProgram = "kotlin-lsp";
  };
}
