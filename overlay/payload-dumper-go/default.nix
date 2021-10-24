{ lib, fetchFromGitHub, buildGoModule, xz }:

buildGoModule rec {
  pname = "payload-dumper-go";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "ssut";
    repo = "payload-dumper-go";
    rev = version;
    sha256 = "1airc6pcv9m06g35jfxvwh5pr1cxhwndny22b0liwvp4hrc99chc";
  };
  vendorSha256 = "1rv98b1fi6n2a0cwh8z4140lkls3n9yzznrydnyl5zndq0a1k8ha";

  buildInputs = [
    xz
  ];

  meta = with lib; {
    description = "an android OTA payload dumper written in Go";
    homepage = "https://github.com/ssut/payload-dumper-go";
    license = licenses.asl20;
  };
}
