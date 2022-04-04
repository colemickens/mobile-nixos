{ stdenv, lib
, makeWrapper
}:

stdenv.mkDerivation {
  name = "pil-squasher";
  version = "2022-05-21";
  
  nativeBuildInputs = [ makeWrapper ];
  
  meta = {
    description = "Convert split mdt + b%02d files into mbn file";
    homepage = "https://github.com/andersson/pil-squasher";
  };
}
