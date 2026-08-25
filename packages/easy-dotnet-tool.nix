{ lib
, stdenvNoCC
, fetchurl
, unzip
, zip
, dotnetCorePackages
}:

let
  pair = import ./easy-dotnet-pair.nix;
  version = pair.serverVersion;
  nupkg = fetchurl {
    url = "https://www.nuget.org/api/v2/package/EasyDotnet/${version}";
    name = "EasyDotnet.${version}.nupkg";
    hash = pair.serverHash;
  };
  # Stage 1: extract nupkg, remove ARM64 dncdbg binaries, repack
  nupkgClean = stdenvNoCC.mkDerivation {
    pname = "EasyDotnet";
    inherit version;
    src = nupkg;
    nativeBuildInputs = [ unzip zip ];
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;
    installPhase = ''
      runHook preInstall
      mkdir tmp
      cd tmp
      unzip -q $src
      rm -rf tools/dncdbg/linux-arm64
      mkdir -p $out
      zip -q -r $out/EasyDotnet.${version}.nupkg .
      runHook postInstall
    '';
  };
in assert lib.assertMsg pair.isCurrentPairRegistered ''
  easy-dotnet drift: server ${pair.serverVersion} does not form a tested pair
  with plugin commit ${pair.pluginRev} (packages/easy-dotnet-pair.nix:knownPairs).
  The server and plugin are protocol-coupled -- bump and verify them together.
''; stdenvNoCC.mkDerivation {
  pname = "easydotnet";
  inherit version;

  src = nupkgClean;

  buildInputs = [ dotnetCorePackages.sdk_8_0 ];

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    export HOME=$TMPDIR/home
    mkdir -p "$HOME"
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    export DOTNET_NOLOGO=1

    mkdir -p $out/share/nuget/source
    cp $src/EasyDotnet.${version}.nupkg $out/share/nuget/source/

    dotnet tool install \
      --tool-path "$out/lib/easydotnet" \
      --add-source "$out/share/nuget/source" \
      --no-cache \
      EasyDotnet --version ${version}

    mkdir -p $out/bin
    ln -s $out/lib/easydotnet/dotnet-easydotnet $out/bin/dotnet-easydotnet

    runHook postInstall
  '';

  meta = with lib; {
    description = "Easy .NET CLI tool for managing .NET projects";
    homepage = "https://github.com/GustavEikaas/easy-dotnet.nvim";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "dotnet-easydotnet";
    platforms = platforms.all;
  };
}