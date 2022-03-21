{ mobile-nixos
, fetchFromGitLab
, ...
}:

mobile-nixos.kernel-builder rec {
  version = "5.17.0-rc6";
  configfile = ./config.aarch64;

  # Exact copy of:
  #  - https://git.linaro.org/people/vinod.koul/kernel.git/log/?h=topic/gsi7-pixel
  #  - https://git.linaro.org/people/vinod.koul/kernel.git/commit/?h=topic/gsi7-pixel&id=d5ca4c5de8b28496ad565c91e974d8b2448bc80b
  src = fetchFromGitLab {
    owner = "sdm845-mainline";
    repo = "linux";
    rev = "45d697aa3df5638e6f6f08c40570488f716a6334";
    hash = "sha256-qZsbQ56Plv06g+RNlsboM/6QqnQU2UKJRf7E5QzQQJQ=";
  };

  # patches = [
  #   ./0001-arm64-dts-google-blueline-add-gpu.patch
  # ];

#  patches = [
#    ./0001-HACK-Add-back-TEXT_OFFSET-in-the-built-image.patch
#  ];

  # TODO: generic mainline build; append per-device...
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
      $buildRoot/arch/arm64/boot/dts/qcom/sdm845-google-blueline.dtb \
      > $out/Image.${isCompressed}-dtb
    )
  '';

  isModular = false;
  isCompressed = "gz";
  kernelFile = "Image.${isCompressed}-dtb";
}
