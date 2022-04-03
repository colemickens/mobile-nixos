{ mobile-nixos
, fetchFromGitLab
, ...
}:


# TODO:
# https://github.com/LineageOS/android_device_google_crosshatch/commit/4bfc2e65eb61e549c6188203fde0d5de42902eeb



# there are just many ways to do this:
# append dtb to kernel
# embed in bootimg with mkbootimg
# put into a dtbo image and flash the partition
# everything except append-to-kernel requires special bootloader support tho
mobile-nixos.kernel-builder rec {
  version = "5.17.0-rc6";
  configfile = ./config.aarch64;

  src = fetchFromGitLab {
    owner = "sdm845-mainline";
    repo = "linux";
    rev = "45d697aa3df5638e6f6f08c40570488f716a6334";
    hash = "sha256-qZsbQ56Plv06g+RNlsboM/6QqnQU2UKJRf7E5QzQQJQ=";
  };

  patches = [
    ./0001-dtb-fixups.patch
    ./0001-HACK-Firmware-and-files-snooper.5-13.patch
  ];

  # caleb's branch has this already
  #  patches = [
  #    ./0001-HACK-Add-back-TEXT_OFFSET-in-the-built-image.patch
  #  ];

  postInstall = ''
    echo ':: Copying kernel'
    (PS4=" $ "; set -x
    cp -v \
      $buildRoot/arch/arm64/boot/Image.${isCompressed} \
      $out
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
