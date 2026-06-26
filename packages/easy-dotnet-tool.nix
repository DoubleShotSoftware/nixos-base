{ lib
, buildDotnetGlobalTool
, dotnetCorePackages
}:

buildDotnetGlobalTool {
  pname = "easydotnet";  # Use lowercase for the tool name
  # Latest stable on NuGet. Protocol-coupled to the easy-dotnet.nvim plugin
  # commit in ../vimPlugins/easy-dotnet.nix -- bump BOTH together. The plugin's
  # `dotnet.lua` prepends this server's bin to PATH so this pinned version (not
  # the host's auto-updating ~/.dotnet/tools install) is what nvim launches.
  version = "3.2.12";

  # NuGet package name (case-sensitive as it appears on NuGet)
  nugetName = "EasyDotnet";

  # The tool installs as "dotnet-easydotnet"
  # The executable should be specified
  executables = [ "dotnet-easydotnet" ];

  # 3.2.12 targets net8.0 with rollForward=LatestMajor, so the 8.0 runtime is fine.
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  # SHA256 hash of the NuGet package
  # This will need to be updated when updating the version
  nugetSha256 = "sha256-mTvcx3/ef42nv1/k3FijV/55H4DzBHWv/rFgh/AHfJ0=";

  meta = with lib; {
    description = "Easy .NET CLI tool for managing .NET projects";
    homepage = "https://github.com/GustavEikaas/easy-dotnet.nvim";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "dotnet-easydotnet";
    platforms = platforms.all;
  };
}
