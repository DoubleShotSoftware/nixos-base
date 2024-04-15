{ lib, stdenv, callPackage, pkgs, fetchurl, fetchzip, kernel ? null, perl, cfg
, nukeReferences, which, libarchive, config, prePatch ? null, postPatch ? null
, patchFlags ? null, patches ? [ ], preInstall ? null, postInstall ? null }:
with lib;
with builtins;
let
  myVgpuVersion = cfg.vgpuVersion;

  libPathFor = pkgs:
    lib.makeLibraryPath (with pkgs; [
      libdrm
      zlib
      stdenv.cc.cc
      mesa
      libGL
      openssl
      dbus
      xz
      glibc
      gcc
      zstd
    ]);
in stdenv.mkDerivation (finalAttrs: {
  pname = "nvidia_vgpu";
  version = myVgpuVersion;
  src = pkgs.fetchurl {
    name = "NVIDIA-Linux-x86_64-${myVgpuVersion}-vgpu-kvm-custom.run";
    url = cfg.custom_package_url;
    sha256 = cfg.custom_package_sha;
  };
  builder = ./builder.sh;
  ccLib = "${pkgs.stdenv.cc.cc.lib}";
  vgpuVersion = "${myVgpuVersion}";

  nativeBuildInputs = (with pkgs; [
    perl
    nukeReferences
    which
    libarchive
    xz
    coreutils
    glibc
    gcc
    zstd
  ]) ++ kernel.moduleBuildDependencies;
  buildInputs =
    (with pkgs; [ perl libarchive unzip tree bash coreutils xz glibc gcc zstd ])
    ++ kernel.moduleBuildDependencies;
  kernel = kernel.dev;
  kernelVersion = kernel.modDirVersion;
  outputs = [ "out"  ];
  makeFlags = (kernel.makeFlags ++ [
    "IGNORE_PREEMPT_RT_PRESENCE=1"
    "NV_BUILD_SUPPORTS_HMM=1"
    "SYSSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
    "SYSOUT=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ]);
  dontStrip = true;
  dontPatchELF = true;
  bin = true;
  buildFlags = [ "modules" ];
  libPath = libPathFor pkgs;
  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];
  installTargets = [ "modules_install" ];
  postPatch = ''
    # Move path for vgpuConfig.xml into /etc
        sed -i 's|/usr/share/nvidia/vgpu|/etc/nvidia-vgpu-xxxxx|' nvidia-vgpud

    substituteInPlace sriov-manage \
      --replace lspci ${pkgs.pciutils}/bin/lspci \
      --replace setpci ${pkgs.pciutils}/bin/setpci
  '';
  # HACK: Using preFixup instead of postInstall since nvidia-x11 builder.sh doesn't support hooks
  postInstall = "";
  meta = with lib; {
    description = "NVIDIA vGPU driver";
    homepage = "https://www.nvidia.com/en-us/data-center/virtual-solutions";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
})
