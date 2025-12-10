{ lib
, stdenv
, fetchzip
, gettext
, python3
, cockpit
}:

stdenv.mkDerivation rec {
  pname = "cockpit-machines";
  # Pin to cockpit's version for compatibility
  version = cockpit.version or "338";

  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit-machines/releases/download/${version}/cockpit-machines-${version}.tar.xz";
    # This hash will need to be updated when cockpit version changes
    # You can get the correct hash by running:
    # nix-prefetch-url --unpack https://github.com/cockpit-project/cockpit-machines/releases/download/${version}/cockpit-machines-${version}.tar.xz
    sha256 = "13b3f8xn5ns2r1chkqk55afzxpamy6zcw1nink3rc740yaqngmbl";
  };

  nativeBuildInputs = [
    gettext
  ];

  makeFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace /usr/share $out/share
    touch pkg/lib/cockpit.js
    touch pkg/lib/cockpit-po-plugin.js
    touch dist/manifest.json
  '';

  postFixup = ''
    # Fix manifest.json path condition for NixOS
    # Cockpit-machines checks for /usr/share/dbus-1/system.d/org.libvirt.conf
    # but NixOS puts it in /run/current-system/sw/share/dbus-1/system.d/
    sed -i 's|/usr/share/dbus-1|/run/current-system/sw/share/dbus-1|g' $out/share/cockpit/machines/manifest.json

    gunzip $out/share/cockpit/machines/index.js.gz

    # Fix Python shebang
    sed -i "s#/usr/bin/python3#${python3}/bin/python3#g" $out/share/cockpit/machines/index.js

    # Remove pwscore reference (not typically available/needed)
    sed -i "s#/usr/bin/pwscore#/usr/bin/env pwscore#ig" $out/share/cockpit/machines/index.js

    # Replace virtqemud references with libvirtd for NixOS compatibility
    # NixOS uses monolithic libvirtd instead of modular virtqemud
    # This is still needed even with libvirt-dbus for systemctl commands
    sed -i "s#virtqemud#libvirtd#g" $out/share/cockpit/machines/index.js

    gzip -9 $out/share/cockpit/machines/index.js
  '';

  dontBuild = true;

  meta = with lib; {
    description = "Cockpit UI for virtual machines";
    longDescription = ''
      A Cockpit plugin to manage virtual machines using libvirt.
      Provides a web interface for creating, running, and managing VMs.

      This package connects to libvirt via D-Bus (using libvirt-dbus) or
      falls back to virsh commands. Includes NixOS-specific patches for
      monolithic libvirtd compatibility.

      Note: This package is pinned to match the cockpit version for compatibility.
    '';
    license = licenses.lgpl21;
    homepage = "https://github.com/cockpit-project/cockpit-machines";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}