{ stdenv
, fetchFromGitHub
, dtc
, gcc-arm-embedded
, python3
, buildTarget ? "lk1st-msm8916"
, outputFile ? "emmc_appsboot.mbn"
}:

# TODO: 
# this isn't generic enough to be useful :/

let
  python = (python3.withPackages (p: [
    p.libfdt
  ]));
in
stdenv.mkDerivation {
  pname = "lk2nd";
  version = "openstick-abaec6";
  
  src = fetchFromGitHub {
    owner = "colemickens";
    repo = "openstick-lk2nd";
    rev = "abaec6e6f69db058720929553581bc46348fdfbc";
    sha256 = "sha256-oFLvkH3waLXAnNu6VktFvpPIttpBCDdpZjt4lY6rLv0=";
  };
  postPatch = ''
    patchShebangs --build scripts/{dtbTool,mkbootimg}
  '';
  
  nativeBuildInputs = [
    gcc-arm-embedded
    dtc
    python
  ];
  buildInputs = [];
  
  makeFlags = [
    buildTarget
    "TOOLCHAIN_PREFIX=arm-none-eabi-"
    "LD=arm-none-eabi-ld"
  ];
  
  # doCheck = false; # lord, I'm lazy and they're slow
  # they passed once, so... meh
  
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -prv "build-${buildTarget}/${outputFile}" $out/
    runHook postInstall
  '';
  
  meta = {
    # TODO: https://github.com/msm8916-mainline/lk2nd  
  };
}
