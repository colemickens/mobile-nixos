{ lib, stdenv, meson, ninja, pkg-config, fetchFromGitLab
, python3, gobject-introspection
}:

let metadata = import ./metadata.nix; in
stdenv.mkDerivation rec {
  pname = "libmbim";
  version = metadata.rev;

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "mobile-broadband";
    repo = "libmbim";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  nativeBuildInputs = [
    meson ninja pkg-config
    gobject-introspection python3
  ];

  buildInputs = [
    #glib udev libgudev polkit ppp libmbim libqmi systemd dbus
  ];

  mesonFlags = [
    "-Dintrospection=enabled"
    "-Dvapi=false"
    "-Dman=disabled"
    "-Dgtk_doc=false"
    "-Dbash_completion=false"
  ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "WWAN modem manager, part of NetworkManager";
    homepage = "https://www.freedesktop.org/wiki/Software/ModemManager/";
    license = licenses.gpl2Plus;
    maintainers = teams.freedesktop.members;
    platforms = platforms.linux;
  };
}
