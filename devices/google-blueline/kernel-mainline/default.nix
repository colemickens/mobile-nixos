{ mobile-nixos
, sdm845
, fetchFromGitLab
, runCommandNoCC
, ...
}:

# TODO:
# https://github.com/LineageOS/android_device_google_crosshatch/commit/4bfc2e65eb61e549c6188203fde0d5de42902eeb

let
  isModular = false;
  isCompressed = "gz";
  kernelFile = "Image.${isCompressed}";
  
  blueKernel = mobile-nixos.kernel-builder (opts // {
    patches = [
      ./0001-HACK-Firmware-and-files-snooper.5-13.patch
    ];
    postInstall = ''
      echo ':: Copying kernel'
      (PS4=" $ "; set -x
      cp -v \
        $buildRoot/arch/arm64/boot/Image.${isCompressed} \
        $out/
      )
    '';
  });
  modKernel = mobile-nixos.kernel-builder (opts // {
    patches = [
      ./0001-dtb-fixups.patch
      ./0001-HACK-Firmware-and-files-snooper.5-13.patch
    ];
    dontBuild = true;
    bypassInstall = true;
    overrideBuildFlags = [ ];
    overrideInstallTargets = [ ];
  });
  dtbKernel = modKernel;

  opts = rec {
    version = "5.17.0-rc6";
    configfile = ./config.aarch64;

    src = fetchFromGitLab {
      owner = "sdm845-mainline";
      repo = "linux";
      rev = "45d697aa3df5638e6f6f08c40570488f716a6334";
      hash = "sha256-qZsbQ56Plv06g+RNlsboM/6QqnQU2UKJRf7E5QzQQJQ=";
    };

    # caleb's branch has this already
    #  patches = [
    #    ./0001-HACK-Add-back-TEXT_OFFSET-in-the-built-image.patch
    #  ];
    
    
    inherit isModular isCompressed kernelFile;
  };

  device = "google-blueline";
in
sdm845.tools.appendDtb
  device
  blueKernel
  "${dtbKernel}/dtbs/qcom/sdm845-${device}.dtb"

