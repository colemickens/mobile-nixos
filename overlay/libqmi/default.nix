{ stdenv, lib, fetchFromGitLab
, libdrm, json_c
, meson, ninja, pkg-config
, python3, gobject-introspection, gtk-doc
, glib, libgudev, libmbim, libqrtr-glib
}:

let
  rev = "4210314cbd37142ceb5328ed14007b36338b3658";
in stdenv.mkDerivation rec {
  pname = "libqmi";
  version = rev;

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "mobile-broadband";
    repo = pname;
    rev = rev;
    sha256 = "sha256-Rbdx7TRtN1NJrW2F5/NQsTX/HtclGu7uLf2cm7fddfI=";
  };

  patchPhase = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    meson ninja pkg-config
    python3 gobject-introspection gtk-doc
  ];
  
  buildInputs = [
    glib libgudev libmbim libqrtr-glib
  ];

  mesonFlags = [
    "-Dintrospection=enabled"
    "-Dgtk_doc=false"
    "-Dbash_completion=false"
    "-Dman=disabled"
  ];
  /*
    option('collection', type: 'combo', choices: ['minimal', 'basic', 'full'], value: 'full', description: 'message collection to build')
    option('firmware_update', type: 'boolean', value: true, description: 'enable compilation of `qmi-firmware-update')
    option('mbim_qmux', type: 'feature', value: 'auto', description: 'enable support for QMI over MBIM QMUX service')
    option('mm_runtime_check', type: 'boolean', value: true, description: 'build ModemManager runtime check support')
    option('qmi_username', type: 'string', value: '', description: 'user allowed to access QMI devices')
    option('qrtr', type: 'feature', value: 'auto', description: 'enable support for QRTR protocol')
    option('rmnet', type: 'feature', value: 'auto', description: 'enable support for RMNET link management')
    option('udev', type: 'feature', value: 'auto', description: 'build udev support')
    option('udevdir', type: 'string', value: '', description: 'where udev base directory is')
    option('introspection', type: 'feature', value: 'auto', description: 'build introspection support')
    option('gtk_doc', type: 'boolean', value: false, description: 'use gtk-doc to build documentation')
    option('bash_completion', type: 'boolean', value: true, description: 'install bash completion files')
    */
}
