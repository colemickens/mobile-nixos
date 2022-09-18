{ lib, fetchFromGitHub, buildGoModule, xz }:

buildGoModule rec {
  pname = "payload-dumper-go";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "ssut";
    repo = "payload-dumper-go";
    rev = version;
    sha256 = "sha256-P20/Nd2YOW9A9/OkpavVRBAi/ueYp812zZvVLnwX67Y=";
  };
  vendorSha256 = "sha256-CqIZFMDN/kK9bT7b/32yQ9NJAQnkI8gZUMKa6MJCaec=";

  buildInputs = [
    xz
  ];

  meta = with lib; {
    description = "an android OTA payload dumper written in Go";
    homepage = "https://github.com/ssut/payload-dumper-go";
    license = licenses.asl20;
  };
}
