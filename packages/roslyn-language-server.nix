{ lib, stdenvNoCC, fetchurl, unzip }:

let
  version = "5.9.0-1.26303.1";
in stdenvNoCC.mkDerivation {
  pname = "roslyn-language-server";
  inherit version;

  src = fetchurl {
    url = "https://api.nuget.org/v3-flatcontainer/roslyn-language-server.linux-x64/${version}/roslyn-language-server.linux-x64.${version}.nupkg";
    hash = "sha512-dTqNspdVVoUTtiWAqzYl8RPNOmJ5uv49RiFgYyI9f+9XP1UZ3V6dZDBP2yvbGFMLMwaYwli2s2WFw7jaax6zlw==";
    name = "roslyn-language-server.linux-x64.${version}.nupkg";
  };

  nativeBuildInputs = [ unzip ];

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  unpackPhase = ''
    runHook preUnpack
    mkdir nupkg
    cd nupkg
    unzip -q $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/roslyn-ls
    # The actual server DLLs are under tools/net10.0/linux-x64/
    cp -r tools/net10.0/linux-x64/* $out/lib/roslyn-ls/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Microsoft Roslyn Language Server (nightly)";
    homepage = "https://github.com/dotnet/roslyn";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}