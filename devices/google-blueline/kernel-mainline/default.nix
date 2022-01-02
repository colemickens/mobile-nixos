{ mobile-nixos
, fetchFromGitLab
, ...
}:

mobile-nixos.kernel-builder rec {
  version = "5.16.0-rc5";
  modDirVersion = "5.16.0-rc5";
  configfile = ./config.aarch64;
  src = fetchFromGitLab {
    owner = "sdm845-mainline";
    repo = "linux";
    rev = "9ed86f14d0718d81a55708abe5355fd2a8a09b8d";
    sha256 = "sha256-/eBwyhFmBQ0yvbUQ3gv5lNTW7OE0SrwZdy9wVz6lOSA=";
  };

  patches = [
    ./0001-HACK-Add-back-TEXT_OFFSET-in-the-built-image.patch

    # http://git.linaro.org/people/vinod.koul/kernel.git/log/?h=pixel/dsc_v3
    # @ d5fe7f95e41a70eeb000498afd5aed48f9bf96ff
    ./0001-Linaro-blueline-dsc-v3-wip.patch

    # https://git.linaro.org/people/vinod.koul/kernel.git/log/?h=pixel/gpi_i2c_touch
    # @ 1b3424a2994b82ac38fdf16e2136e7811548fea4
    # ./0002-Linaro-blueline-touch.patch
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
