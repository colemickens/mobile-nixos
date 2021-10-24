{stdenv, lib, fetchFromGitHub, qrtr, ...}:

with lib;
with builtins;

stdenv.mkDerivation {
  pname = "qmic-unstable";
  version = "2021-10-04";

  buildInputs = [ qrtr ];

  src = fetchFromGitHub {
    owner = "andersson";
    repo = "qmic";
    rev = "ed896c97dc2b3b7edcba103e02fd0f3368b56ddd";
    sha256 = "0bngy3lm30z3q9f8wabpakl1gzmskd7jxrc06xqxj2nk9bgscnwn";
  };

  installPhase = ''
    make DESTDIR="$out" prefix= install
  '';
}
