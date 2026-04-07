{ lib
, buildDotnetGlobalTool
, dotnetCorePackages
}:

buildDotnetGlobalTool {
  pname = "easydotnet";  # Use lowercase for the tool name
  version = "3.0.9";

  # NuGet package name (case-sensitive as it appears on NuGet)
  nugetName = "EasyDotnet";

  # The tool installs as "dotnet-easydotnet"
  # The executable should be specified
  executables = [ "dotnet-easydotnet" ];

  # Use dotnet runtime 8.0
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  # SHA256 hash of the NuGet package
  # This will need to be updated when updating the version
  nugetSha256 = "sha256-b9E+ziyzKgglK2dqWjy7+BwaNFju/7TNXIKROUtT6GU=";

  meta = with lib; {
    description = "Easy .NET CLI tool for managing .NET projects";
    homepage = "https://github.com/GustavEikaas/easy-dotnet.nvim";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "dotnet-easydotnet";
    platforms = platforms.all;
  };
}
