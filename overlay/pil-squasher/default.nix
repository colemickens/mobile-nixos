{ stdenv, lib
, fetchFromGitHub
, makeWrapper
}:

let
in stdenv.mkDerivation rec {
  name = "pil-squasher";
  version = "2022-05-21";
  
  src = fetchFromGitHub {
    owner = "andersson";
    repo = "pil-squasher";
    rev = "843950ff8445cb02ee543ec751ab42112d39a8e0";
    sha256 = "sha256-bQjyM3NBskR2Yl+TtFltmiK5tHdQpLpOU2EOxkX8JlM=";
  };

  installFlags = [
    "CFLAGS=-Wno-warn-unused"
    "prefix=${placeholder "out"}"
  ];
    
  nativeBuildInputs = [ makeWrapper ];
  
  meta = {
    description = "Convert split mdt + b%02d files into mbn file";
    homepage = "https://github.com/andersson/pil-squasher";
  };
}
