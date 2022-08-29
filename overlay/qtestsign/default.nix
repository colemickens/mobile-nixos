{ stdenv
, fetchFromGitHub
, python3Packages
, openssl
# , buildPackages
}:

python3Packages.buildPythonApplication rec {
  pname = "qtestsign-unstable";
  version = "2022-07-04";
  
  src = fetchFromGitHub {
    owner = "msm8916-mainline";
    repo = "qtestsign";
    rev = "931247f65c0a0e581c96d3528a655bf6646d6936";
    sha256 = "sha256-OobXD1TonNOIkxDjLpVU0eZmJRJu/2alHr2RJqZ8aso=";
  };

  # missing python packages of course:
  # cryptography... maybe others
  
  format = "other";
  
  postPatch = ''
    patchShebangs *.py
    chmod +x ./qtestsign.py
  '';
  
  propagatedBuildInputs = with python3Packages; [
    cryptography
  ];
  propagatedNativeBuildInputs = with python3Packages; [
    openssl
    cryptography
    python
  ];

  nativeBuildInputs = [
    python3Packages.cryptography
    python3Packages.wrapPython
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -v $src/* $out/bin/

    chmod +x $out/bin/qtestsign.py
    
    wrapPythonPrograms
  '';
  
  # TODO meta url : https://github.com/msm8916-mainline/qtestsign
}
