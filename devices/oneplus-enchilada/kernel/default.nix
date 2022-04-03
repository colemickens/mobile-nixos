{
  mobile-nixos
, fetchFromGitLab
, fetchpatch
, ...
}:

mobile-nixos.kernel-builder rec {
  # https://gitlab.com/sdm845-mainline/linux/-/tree/sdm845/5.18-dev
  version = "5.17.0";
  modDirVersion = "5.17.0";
  configfile = ./config.aarch64;
  src = fetchFromGitLab {
    owner = "sdm845-mainline";
    repo = "linux";
    rev = "452e02d876234a43cfd9256134ad115b3674e47c";
    sha256 = "sha256-1fp3zH8WG7RGd7C58HX+LVI+8qpeDwxDmmePVpUQ4ls=";
  };

  patches = [
  ];

  postInstall = ''
    echo ':: Copying kernel'
    (PS4=" $ "; set -x
    cp -v \
      $buildRoot/arch/arm64/boot/Image.${isCompressed} \
      $out/
    )
    echo ':: Appending DTB'
    (PS4=" $ "; set -x
    cat \
      $buildRoot/arch/arm64/boot/Image.${isCompressed} \
      $buildRoot/arch/arm64/boot/dts/qcom/sdm845-oneplus-enchilada.dtb \
      > $out/Image.${isCompressed}-dtb
    )
  '';

  isModular = false;
  isCompressed = "gz";
  kernelFile = "Image.${isCompressed}-dtb";
}
