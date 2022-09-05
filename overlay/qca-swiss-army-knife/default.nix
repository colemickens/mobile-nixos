{ stdenv, lib
, writeShellScript
, fetchFromGitHub
, python3
}:

let
  qca-gen-boardbin = writeShellScript "qca-gen-boardbin"
    (builtins.readFile ./qca-gen-boardbin.sh);
in
stdenv.mkDerivation rec {
  name = "qca-swiss-army-knife";
  version = "2022-02-08";
  
  src = fetchFromGitHub {
    owner = "qca";
    repo = "qca-swiss-army-knife";
    rev = "4661dc499481c2acc4a89a89e420acb09a34c66e";
    sha256 = "sha256-5aIXU3V5AwQ+khHe7E9ikuJaE9qxpeUNVj4/JreIfTk=";
  };

  installPhase = ''
    cp -a $src $out
    chmod -R +w $out/
    mkdir $out/bin
  
    patchShebangs $out/**
    cp -a ${qca-gen-boardbin} $out/tools/scripts/ath10k/qca-gen-boardbin

    substituteInPlace \
      $out/tools/scripts/ath10k/ath10k-bdencoder \
        --replace '/usr/bin/python3' '${python3}/bin/python'
    substituteInPlace \
      $out/tools/scripts/ath10k/ath10k-fwencoder \
        --replace '/usr/bin/python3' '${python3}/bin/python'
  
    ln -st $out/bin $out/tools/scripts/ath10k/*
  '';
 
  meta = {
    description = "QCA swiss army knife";
    homepage = "https://github.com/qca/qca-swiss-army-knife";
  };
}
