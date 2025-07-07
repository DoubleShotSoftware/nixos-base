{ lib
, stdenv
, fetchurl
, unzip
, makeWrapper
, dotnet-sdk_8
, dotnetCorePackages
, zlib
, openssl
, icu
}:

stdenv.mkDerivation rec {
  pname = "resharper-cli";
  version = "2025.1.4";

  src = fetchurl {
    url = "https://download.jetbrains.com/resharper/dotUltimate.${version}/JetBrains.ReSharper.CommandLineTools.${version}.zip";
    sha256 = "d70bcb6d9298eb83774115da1366453e72375b2553ab6338d6108d4289015808";
  };

  nativeBuildInputs = [ unzip makeWrapper ];

  buildInputs = [
    dotnet-sdk_8
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
      --prefix PATH : ${lib.makeBinPath [ dotnet-sdk_8 ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

    # CleanupCode
    makeWrapper $out/share/resharper-cli/cleanupcode.sh $out/bin/cleanupcode \
      --prefix PATH : ${lib.makeBinPath [ dotnet-sdk_8 ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

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