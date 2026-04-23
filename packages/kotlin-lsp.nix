# packages/kotlin-lsp.nix
# JetBrains Kotlin Language Server
{
  pkgs,
  lib,
  stdenv,
  fetchzip,
  makeWrapper,
}: let
  version = "262.2310.0";
  platform =
    if stdenv.isDarwin
    then "macos-aarch64"
    else "linux-x64";
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
      mkdir -p $out/lib/kotlin-lsp $out/bin
      cp -r ${src}/. $out/lib/kotlin-lsp/
      substituteInPlace $out/lib/kotlin-lsp/kotlin-lsp.sh \
        --replace 'chmod +x "$LOCAL_JRE_PATH/bin/java"' 'true'
      sed -i '/-Djava.system.class.loader=com.intellij.util.lang.PathClassLoader/d' \
        $out/lib/kotlin-lsp/kotlin-lsp.sh
      chmod +x $out/lib/kotlin-lsp/kotlin-lsp.sh
      chmod +x $out/lib/kotlin-lsp/jre/bin/java
      makeWrapper ${pkgs.bash}/bin/bash $out/bin/kotlin-lsp \
        --add-flags $out/lib/kotlin-lsp/kotlin-lsp.sh
    '';

    meta = with lib; {
      description = "Official Language Server for Kotlin from JetBrains";
      homepage = "https://github.com/Kotlin/kotlin-lsp";
      license = licenses.asl20;
      platforms = ["x86_64-linux" "aarch64-darwin"];
      mainProgram = "kotlin-lsp";
    };
  }
