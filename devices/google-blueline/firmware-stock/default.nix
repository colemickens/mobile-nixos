{ lib
, fetchurl, fetchzip
, payload-dumper-go, unzip
, runCommand
, writeShellScriptBin
}:

let
  # stockVersion = "22.J.62_OTA_0620_all_2111252336_287bcb1636d743d3";
  # stockPayload = fetchurl {
  #   url = "https://oxygenos.oneplus.net/OnePlus6Oxygen_${stockVersion}.zip";
  #   sha256 = "sha256-co0783sSIEAk+z21FIn61mpytuRAcfcnwfeQGZRdce8=";
  # };
  buildID = "sp1a.210812.016.c2";
  buildTag = "fa981d87";
  stockPayload = fetchzip {
    url = "https://dl.google.com/dl/android/aosp/blueline-${buildID}-factory-${buildTag}.zip";
    sha256 = "sha256-JGBOg8sNpxO11LFIa7hDuS9wW3UmRRnWureb8GcxniM=";
  };
  stockFirmware = runCommand "blueline-stock-fw" { nativeBuildInputs = [unzip]; } ''
    set -x
    mkdir $out
    cd "${stockPayload}"
    cp bootloader*img $out/
    cp radio*img $out/
    
    unzip image*zip -d $out/
  '';

  resetScript = (writeShellScriptBin "reset-blueline.sh" ''
    which fastboot || (echo "you must have fastboot available" && exit -1)

    cd "${stockFirmware}"
    pwd
    slots="a b"
    for slot in $slots; do
      fastboot set_active $slot

      cd "${stockFirmware}"
      fastboot flash bootloader bootloader*img
      fastboot flash radio radio*img

      # fastboot flash boot boot.img # skip for now
      # fastboot flash system system.img # skip for now

      # fastboot flash vendor vendor.img # must be flashed from fastbootd...
      # fastboot flash product product.img # must be flashed from fastbootd...

      # TODO: enchilada was picky about this, do we need to be for blueline? what if system is wiped?
      fastboot flash vbmeta vbmeta.img
      # fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
      
      # mainline/bootloader requires dtbo wiped to load DTB from end of kernel:
      # TODO: consider breaking this into a separate script/step
      fastboot erase dtbo
    done
    
    fastboot set_active a
   '');
in
  resetScript
