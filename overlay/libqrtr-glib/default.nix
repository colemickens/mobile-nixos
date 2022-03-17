{ stdenv, lib, fetchFromGitLab
, libdrm, json_c
, meson, ninja, pkg-config
, gtk-doc
, glib, gobject-introspection
}:

let
  rev = "524628b3abafcd007433978efc293a57e9f39c6c";
in stdenv.mkDerivation rec {
  pname = "libqrtr-glib";
  version = rev;

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "mobile-broadband";
    repo = pname;
    rev = rev;
    sha256 = "sha256-0iTXfdN50mGhTuz83ST+ZQ2wQawXk/+Kw3cVTThtByg=";
  };

  nativeBuildInputs = [
    meson ninja pkg-config
    gtk-doc
    gobject-introspection
  ];
  
  buildInputs = [
    glib
  ];

   mesonFlags = [
    "-Dintrospection=enabled"
    "-Dgtk_doc=false"
  ];
}
