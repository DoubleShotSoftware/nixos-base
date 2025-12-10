{ lib
, stdenv
, fetchFromGitLab
, meson
, ninja
, pkg-config
, python3
, glib
, libvirt
, libvirt-glib
, systemd
}:

stdenv.mkDerivation rec {
  pname = "libvirt-dbus";
  version = "1.4.1";

  src = fetchFromGitLab {
    owner = "libvirt";
    repo = "libvirt-dbus";
    rev = "v${version}";
    sha256 = "sha256-S4QktQmcnTte4XsIcgc5dkA8LjMJaOD2lljS01WT0dk=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    (python3.withPackages (ps: [ ps.docutils ]))  # Provides rst2man
  ];

  buildInputs = [
    glib
    libvirt
    libvirt-glib
    systemd
  ];

  postPatch = ''
    # Fix systemd service installation paths to use our output directory
    substituteInPlace meson.build \
      --replace-fail "systemd_dep.get_pkgconfig_variable('systemduserunitdir')" "'$out/lib/systemd/user'" \
      --replace-fail "systemd_dep.get_pkgconfig_variable('systemdsystemunitdir')" "'$out/lib/systemd/system'"
  '';

  mesonFlags = [
    "-Dsystem_user=root"
    "-Dunix_socket_group=libvirtd"
  ];

  meta = with lib; {
    description = "D-Bus API for libvirt";
    longDescription = ''
      libvirt-dbus wraps libvirt API to provide a high-level object-oriented
      API better suited for dbus-based applications. It provides an alternative
      to using libvirt's native bindings for languages and tools that prefer
      D-Bus communication.

      This is required for tools like Cockpit to manage libvirt over D-Bus.
    '';
    homepage = "https://libvirt.org/dbus.html";
    license = licenses.lgpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
