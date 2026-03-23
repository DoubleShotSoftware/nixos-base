{ lib
, stdenv
, fetchurl
, unzip
, makeWrapper
, dotnetSDK
, zlib
, openssl
, icu
}:

stdenv.mkDerivation rec {
  pname = "resharper-cli";
  version = "2025.3.1";

  src = fetchurl {
    url = "https://download.jetbrains.com/resharper/dotUltimate.${version}/JetBrains.ReSharper.CommandLineTools.${version}.zip";
    sha256 = "1hdqji0flggp2w25cbmlz9fml7qfrp6sv0wwjvcg15yar7jfgbfh";
  };

  nativeBuildInputs = [ unzip makeWrapper ];

  buildInputs = [
    dotnetSDK
    stdenv.cc.cc.lib
    zlib
    openssl
    icu
  ];

  dontConfigure = true;
  dontBuild = true;

  # Handle the case where unzip creates multiple directories
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/resharper-cli
    cp -r * $out/share/resharper-cli/

    # Make shell scripts executable
    chmod +x $out/share/resharper-cli/*.sh 2>/dev/null || true

    # Create wrapper scripts for the main executables
    mkdir -p $out/bin

    # The tools come with .sh scripts that handle the runtime config
    # We'll wrap these scripts with the necessary environment
    
    # InspectCode
    makeWrapper $out/share/resharper-cli/inspectcode.sh $out/bin/inspectcode \
      --prefix PATH : ${lib.makeBinPath [ dotnetSDK ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs} \
      --set DOTNET_ROOT ${dotnetSDK}/share/dotnet \
      --set DOTNET_HOST_PATH ${dotnetSDK}/bin/dotnet \
      --set DOTNET_CLI_TELEMETRY_OPTOUT 1 \
      --set DOTNET_NOLOGO true

    # CleanupCode
    makeWrapper $out/share/resharper-cli/cleanupcode.sh $out/bin/cleanupcode \
      --prefix PATH : ${lib.makeBinPath [ dotnetSDK ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs} \
      --set DOTNET_ROOT ${dotnetSDK}/share/dotnet \
      --set DOTNET_HOST_PATH ${dotnetSDK}/bin/dotnet \
      --set DOTNET_CLI_TELEMETRY_OPTOUT 1 \
      --set DOTNET_NOLOGO true

    runHook postInstall
  '';

  meta = with lib; {
    description = "JetBrains ReSharper Command Line Tools";
    longDescription = ''
      Command line tools that provide the ability to run InspectCode 
      and CleanupCode outside of Visual Studio or JetBrains Rider.
      
      Note: This package includes inspectcode and cleanupcode tools.
      The dupfinder tool is not included in this version.
    '';
    homepage = "https://www.jetbrains.com/help/resharper/ReSharper_Command_Line_Tools.html";
    license = licenses.unfree;
    platforms = platforms.unix;
    maintainers = with maintainers; [ ];
  };
}
