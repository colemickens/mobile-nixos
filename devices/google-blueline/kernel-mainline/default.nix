{ mobile-nixos
, fetchFromGitHub
, ...
}:

mobile-nixos.kernel-builder rec {
  version = "5.17.0-rc1";
  configfile = ./config.aarch64;

  # Exact copy of:
  #  - https://git.linaro.org/people/vinod.koul/kernel.git/log/?h=topic/gsi7-pixel
  #  - https://git.linaro.org/people/vinod.koul/kernel.git/commit/?h=topic/gsi7-pixel&id=d5ca4c5de8b28496ad565c91e974d8b2448bc80b
  src = fetchFromGitHub {
    owner = "samueldr";
    repo = "linux";
    rev = "d5ca4c5de8b28496ad565c91e974d8b2448bc80b";
    hash = "sha256-f8uoOV1+HYGZeTYiM48ydHtikbiAqsjURJvH1smo16o=";
  };

  patches = [
    ./0001-HACK-Add-back-TEXT_OFFSET-in-the-built-image.patch
  ];

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
      $buildRoot/arch/arm64/boot/dts/qcom/sdm845-blueline.dtb \
      > $out/Image.${isCompressed}-dtb
    )
  '';

  isModular = false;
  isCompressed = "gz";
  kernelFile = "Image.${isCompressed}-dtb";
}
