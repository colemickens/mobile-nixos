{ lib
, fetchurl
, payload-dumper-go, unzip
, runCommand
, writeShellScriptBin
}:

let
  # note, this somehow also exists: https://androidfilehost.com/?fid=7161016148664850007
  # but doesn't on OP servers...
  # OnePlus6Oxygen_22.J.62_OTA_0620_all_2111252336_14afec75dd6fa.zip
  # stockVersion = "22.J.62_OTA_0620_all_2111252336_14afec75dd6fa.zip
  stockVersion = "22.J.62_OTA_0620_all_2111252336_287bcb1636d743d3";
  stockPayload = fetchurl {
    url = "https://oxygenos.oneplus.net/OnePlus6Oxygen_${stockVersion}.zip";
    sha256 = "sha256-co0783sSIEAk+z21FIn61mpytuRAcfcnwfeQGZRdce8=";
  };
  stockFirmware = runCommand "oneplus-sdm845-stock-firmware" { nativeBuildInputs = [ unzip payload-dumper-go ]; } ''
    tmpdir="$(mktemp -d)"
    unzip "${stockPayload}" -d "$tmpdir"

    mkdir $out
    payload-dumper-go --output "$out" "$tmpdir/payload.bin"
  '';
  resetScript = (writeShellScriptBin "reset-oneplus6.sh" ''
    set -x
    which fastboot || (echo "you must have fastboot available" && exit -1)

    cd "${stockFirmware}"
    pwd
    slots="a"
    for slot in $slots; do
      fastboot set_active $slot

      ## listed on lineage os wiki:
      ## commented out ones don't flash because "critical partitions":
      # fastboot flash abl abl.img
      fastboot flash aop aop.img
      fastboot flash bluetooth bluetooth.img
      # fastboot flash cmnlib cmnlib.img
      # fastboot flash cmnlib64 cmnlib64.img
      # fastboot flash devcfg devcfg.img
      fastboot flash dsp dsp.img
      fastboot flash fw_4j1ed fw_4j1ed.img
      fastboot flash fw_4u1ea fw_4u1ea.img
      # fastboot flash hyp hyp.img
      # fastboot flash keymaster keymaster.img
      fastboot flash LOGO LOGO.img
      fastboot flash modem modem.img
      fastboot flash oem_stanvbk oem_stanvbk.img
      fastboot flash qupfw qupfw.img
      fastboot flash storsec storsec.img
      # fastboot flash tz tz.img
      # fastboot flash xbl xbl.img
      # fastboot flash xbl_config xbl_config.img
      
      ## not listed on lineageos (maybe not firmware, but still)
      fastboot flash --slot=$slot boot boot.img
      fastboot flash --slot=$slot dtbo dtbo.img
      # fastboot flash --slot=$slot system system.img
      fastboot flash vendor vendor.img
      # fastboot flash --slot=$slot india india.img
      # fastboot flash --slot=$slot reserve reserve.img

      # disabling this was required (maybe due to wiping /system partition)
      fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
      
      # mainline/bootloader requires dtbo wiped to load DTB from end of kernel:
      # TODO: consider breaking this into a separate script/step
      # fastboot erase dtbo
    done
    
    fastboot set_active a
   '');
in
  resetScript
