{ runCommandNoCC
, lib
, firmwareLinuxNonfree
, mobile-nixos
, wireless-regdb
, vendor-firmware-files
}:

let
  pils = "${mobile-nixos.pil-squasher}/bin/pil-squasher";
  
  firmware-oem = "mobile-nixos"; # TODO do the kernel param side
in
  
# The minimum set of firmware files required for the device.
runCommandNoCC "google-blueline-firmware" {
  version = vendor-firmware-files.version;
  src = firmwareLinuxNonfree;
  nativeBuildInputs = [ mobile-nixos.pil-squasher ];
  meta.license = [ lib.licenses.unfree ];
} ''
  # Firmware from the vendor image
    
  # general dumping dir
  pixel3fw="$out/lib/firmware/qcom/sdm845/pixel3"
  mkdir -p $pixel3fw

  # TODO:   # sleep 100  # slpi.mbn # neural core    # wlanmdsp.bin # ????
  find ${vendor-firmware-files} | sort

  # CIRRUS
  # cs40l20.bin
  # cs40l20.wmfw
  
  # HAPTICS
  # drv2625.bin
    
  # ADSP/CDSP = Qualcomm "application DSP" (Compute DSP) + Audio DSP
  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/*adsp*.{mbn,jsn}
  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/*cdsp*.{mbn,jsn}
  
  # VENUS - video accel
  venusfw="$out/lib/firmware/qcom/venus-5.2"
  mkdir -p $venusfw
  cp -vt "$venusfw" ${vendor-firmware-files}/lib/firmware/*venus*

  # GPU - ADRENO 630 
  gpufw="$out/lib/firmware/qcom"
  mkdir -p $gpufw
  (cd ${vendor-firmware-files}/lib/firmware/
    ls
    pil-squasher "$gpufw/a630_zap.mbn" ./a630_zap.mdt
  )
  
  # BT
  btfw="$out/lib/firmware/${firmware-oem}/qca"
  mkdir -p $btfw
  cp -vt "$btfw" ${vendor-firmware-files}/lib/firmware/*crbtfw*

  btqcafw="$out/lib/firmware/${firmware-oem}/qca/"
  mkdir -p $btqcafw
  cp -vt "$btqcafw" ${vendor-firmware-files}/lib/firmware/*crnv*

  # WIFI
  # pmos:  lib/firmware/postmarketos/ath10k/WCN3990/hw1.0/board-2.bin
  qcomwififw="$out/lib/firmware/qca/qcom"
  mkdir -p $qcomwififw

  # WIFI REGDB (upstream) ?
  cp -vt $out/lib/firmware ${wireless-regdb}/lib/firmware/regulatory.db*
    
  # MODEM
  (cd ${vendor-firmware-files}/lib/firmware/
    ls
    pil-squasher "$pixel3fw/modem.mbn" ./modem.mdt
  )
  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/*modem*.jsn

  # TOUCH SCREEN PANEL
  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/ftm5*.ftb


  # OLD: likely just purge:
  # Firmware we can get from upstream
  # TODO: still unclear on exactly what to take from upstream and not:
  #
  # for firmware in \
  #   qca/crbtfw21.tlv \
  #   qca/crnv21.bin \
  # ; do
  #   mkdir -p "$(dirname $out/lib/firmware/$firmware)"
  #   cp -vrf "$src/lib/firmware/$firmware" $out/lib/firmware/$firmware
  # done
''
