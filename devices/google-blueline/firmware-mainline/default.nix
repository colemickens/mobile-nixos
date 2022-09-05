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
  qcomfw="$out/lib/firmware/qca/qcom"
  qcafw="$out/lib/firmware/qca"
  gpu_qcomfw="$out/lib/firmware/qcom"
  venusfw="$out/lib/firmware/qcom/venus-5.2"
  mkdir -p $pixel3fw
  mkdir -p $qcomfw
  mkdir -p $qcafw
  mkdir -p $gpu_qcomfw
  mkdir -p $venusfw

  find ${vendor-firmware-files} | sort
  # sleep 100

  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/*adsp*
  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/*cdsp*
  
  # copied from pmos
  # ipa_fws.mbn # nfc
  # slpi.mbn # neural core
  # venus.mbn # video hardware ???
  # wlanmdsp.bin # ????
  
  # video accel
  # venus
  cp -vt "$venusfw" ${vendor-firmware-files}/lib/firmware/*venus*

  # GPU (mainly)
  # TODO: CLEAN THIS UP
  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/*a630*
  cp -vt "$qcomfw" ${vendor-firmware-files}/lib/firmware/*a630*
  cp -vt "$gpu_qcomfw" ${vendor-firmware-files}/lib/firmware/*a630*
  cp -vt "$qcafw" ${vendor-firmware-files}/lib/firmware/*a630*
  
  # BT
  cp -vt "$qcomfw" ${vendor-firmware-files}/lib/firmware/*crbtfw*
  cp -vt "$qcafw" ${vendor-firmware-files}/lib/firmware/*crbtfw*
  cp -vt "$qcafw" ${vendor-firmware-files}/lib/firmware/*crnv*

  # Modem stuff
  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/*mba*
  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/*modem*

  # Touch panel
  cp -vt "$pixel3fw" ${vendor-firmware-files}/lib/firmware/ftm5*.ftb

  # (
  #   cd $out/lib/firmware/qcom
  #   for f in sdm845/pixel3/*; do
  #    ln -sf $f
  #   done
  # )

  # # Firmware we can get from upstream
  # for firmware in \
  #   qca/crbtfw21.tlv \
  #   qca/crnv21.bin \
  # ; do
  #   mkdir -p "$(dirname $out/lib/firmware/$firmware)"
  #   cp -vrf "$src/lib/firmware/$firmware" $out/lib/firmware/$firmware
  # done

  cp -vt $out/lib/firmware ${wireless-regdb}/lib/firmware/regulatory.db*
  
  cd $out/lib/firmware/qcom/sdm845/pixel3
  ln -s a630_zap.mdt a630_zap.mbn
  ln -s adsp.mdt adsp.mbn
  # ln -s cdsp.mdt cdsp.mbn # already exists
  ln -s modem.mdt modem.mbn
  ln -s venus.mdt venus.mbn

  # ls -R -al $out
  # exit -1
''
