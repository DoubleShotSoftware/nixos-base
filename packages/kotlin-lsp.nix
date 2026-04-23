# packages/kotlin-lsp.nix
# JetBrains Kotlin Language Server
{ pkgs, lib, stdenv, fetchzip, makeWrapper, jdk17 }:

let
  version = "262.2310.0";
  platform = if stdenv.isDarwin then "macos-aarch64" else "linux-x64";
  src = fetchzip {
    url = "https://download-cdn.jetbrains.com/kotlin-lsp/${version}/kotlin-lsp-${version}-${platform}.zip";
    hash = "sha256-Bf2qkFpNhQC/Mz563OapmCXeKN+dTrYyQbOcF6z6b48=";
    stripRoot = false;
  };
in
stdenv.mkDerivation {
  pname = "kotlin-lsp";
  inherit version;
  inherit src;

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.bash}/bin/bash $out/bin/kotlin-lsp \
      --add-flags ${src}/kotlin-lsp.sh \
      --set JAVA_HOME ${jdk17} \
      --set JDK_HOME ${jdk17} \
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
