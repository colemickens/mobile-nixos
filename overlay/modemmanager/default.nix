{ lib, stdenv, meson, ninja, fetchFromGitLab
, glib, udev, libgudev, polkit, ppp, gettext, pkg-config, python3
, libmbim, libqmi, libqrtr-glib, systemd, vala, gobject-introspection, dbus
, libxslt
}:

let metadata = import ./metadata.nix; in
stdenv.mkDerivation rec {
  pname = "modemmanager";
  version = metadata.rev;

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "mobile-broadband";
    repo = "modemmanager";
    rev = metadata.rev;
    sha256 = metadata.sha256;
  };

  nativeBuildInputs = [
    meson ninja vala pkg-config
    gobject-introspection gettext
    libxslt.bin
  ];

  buildInputs = [
    glib udev libgudev polkit ppp systemd dbus
    libmbim libqmi libqrtr-glib
  ];

  mesonFlags = [
    "-Dudev=enabled"
    "-Dudevdir=${placeholder "out"}/lib/udev"
    "-Dsystemdsystemunitdir=${placeholder "out"}/etc/systemd/system"

    "-Dmbim=disabled" # libmbim requires a codegen tool, gonna have to look into it
    "-Dqrtr=disabled" # otherwise there's an issue because it doesn't include qrtr headers
    "-Dqmi=disabled" # see above

    "-Dplugin_qcom_soc=disabled" # see above :/

    "-Dintrospection=enabled"
    "-Dvapi=false"
    "-Dman=false"
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
