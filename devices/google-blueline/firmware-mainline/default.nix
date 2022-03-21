{ runCommandNoCC
, firmwareLinuxNonfree
, wireless-regdb
, vendor-firmware-files
}:

# The minimum set of firmware files required for the device.
runCommandNoCC "google-blueline-firmware" {
  src = firmwareLinuxNonfree;
} ''
  # Firmware from the vendor image
  pixel3fw="$out/lib/firmware/qcom/sdm845/pixel3"
  mkdir -p $pixel3fw

  find ${vendor-firmware-files}

  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/*adsp*
  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/*cdsp*
  
  # copied from pmos
  # ipa_fws.mbn # nfc
  # slpi.mbn # neural core
  # venus.mbn # video hardware ???
  # wlanmdsp.bin # ????

  # GPU (mainly)
  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/*a630*

  # Modem stuff
  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/*mba*
  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/*modem*

  # Touch panel
  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/ftm5*.ftb

  (
    cd $out/lib/firmware/qcom
    for f in sdm845/pixel3/*; do
     ln -sf $f
    done
  )

  # Firmware we can get from upstream
  for firmware in \
    qca/crbtfw21.tlv \
    qca/crnv21.bin \
  ; do
    mkdir -p "$(dirname $out/lib/firmware/$firmware)"
    cp -vrf "$src/lib/firmware/$firmware" $out/lib/firmware/$firmware
  done
  cp -vt $out/lib/firmware ${wireless-regdb}/lib/firmware/regulatory.db*
''
