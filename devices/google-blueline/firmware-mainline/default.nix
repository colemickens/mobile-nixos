{ runCommandNoCC
, lib
, firmwareLinuxNonfree
, mobile-nixos
, wireless-regdb
, vendor-firmware-files
}:

let
  pils = "${mobile-nixos.pil-squasher}/bin/pil-squasher";
  
  firmware_class_path = "mobile-nixos"; # TODO do the kernel param side
in
  
# The minimum set of firmware files required for the device.
runCommandNoCC "google-blueline-firmware" {
  version = vendor-firmware-files.version;
  src = firmwareLinuxNonfree;
  nativeBuildInputs = [ mobile-nixos.pil-squasher ];
  meta.license = [ lib.licenses.unfree ];
} ''
  # Firmware from the vendor image
    
  ## layout notes:
  ## following postmarketos (or at least sdm845-mainline):
  
  ## ref: https://gitlab.com/sdm845-mainline/pmaports/-/blob/9903b9539ed957de45d6fbde37c4b74fac5ae711/device/testing/firmware-google-pixel3/30-gpu-firmware.files
  ## ref: https://gitlab.com/sdm845-mainline/pmaports/-/blob/9903b9539ed957de45d6fbde37c4b74fac5ae711/device/testing/firmware-google-pixel3/firmware.files
  
  ## explainer: https://matrix.to/#/!xgUMIsYnSIXklwbhrG:postmarketos.org/$FvogeaBt4OnHmr5AhVskbSdm8bQ7GG28ztr7ajeGux4

  fw="$out/lib/firmware"
  fw_qcom="$out/lib/firmware/qcom"
  fw_qcom_p3="$out/lib/firmware/qcom/sdm845/pixel"
  fw_qca_p3="$out/lib/firmware/qca/pixel3"
  mkdir -p $fwqcom $fw_qcom_p3 $fw_qca_p3

  fw_os="$out/lib/firmware/${firmware_class_name}"
  fw_os_ath="${fw_os}/ath10k/WCN3900/hw1.0/"
  fw_os_qca="${fw_os}/qca"
  mkdir -p $fw_os_qca $fw_os_ath10k
  
  # CIRRUS
  # cs40l20.bin
  # cs40l20.wmfw
  # crus_sp_config_b1_rx.bin ? tx too?
  # cpe_9340.m{} # also audio related?
  
  # HAPTICS
  # drv2625.bin

  # OTHER from firmware?
  # - slpi.mbn
  # - wlanmdsp.bin
  # - wifi? - wil6210.brd
  # - wifi? - wil620.fw
  # - bdwlan-blueline{,-EVT1.0,-EVT1.1}.bin 
    
  # MISSING FROM PMOS:
  # - ./lib/firmware/postmarketos/ath10k/WCN3990/hw1.0/board-2.bin
  # - ./lib/firmware/qcom/sdm845/pixel3/wlanmdsp.mbn

  # TODO: what about "a630_zap.elf" from vendor-fw?
    
  # ADSP/CDSP = Qualcomm "application DSP" (Compute DSP) + Audio DSP
  (cd ${vendor-firmware-files}/lib/firmware/
    pil-squasher "$fw_qcom_p3/adsp.mbn" ./adsp.mdt
    pil-squasher "$fw_qcom_p3/cdsp.mbn" ./cdsp.mdt
  )
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/*adsp*.{mbn,jsn}
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/*cdsp*.{mbn,jsn}
  # TODO: qdsp6m.qdb  from vendor-fw?
  
  # SLPI - slpi.mdt - "low power island" "sensor DSP"
  # TODO
  
  # VENUS - video accel
  (cd ${vendor-firmware-files}/lib/firmware/
    pil-squasher "$fw_qcom_p3/venus.mbn" ./venus.mdt
  )

  # GPU - ADRENO 630 
  (cd ${vendor-firmware-files}/lib/firmware/
    pil-squasher "$fw_qcom_p3/a630_zap.mbn" ./a630_zap.mdt
  )
  cp -vt "$fw_qcom" ${vendor-firmware-files}/lib/firmware/a630_sqe.fw #TODO: from upstream instead?
  cp -vt "$fw_qcom" ${vendor-firmware-files}/lib/firmware/a630_gmu.bin   #TODO: from upstream instead?
  
  # BT
  cp -vt "$fw_qca_p3" ${vendor-firmware-files}/lib/firmware/crnv21.bin
  cp -vt "$fw_os_qca" ${vendor-firmware-files}/lib/firmware/crbtfw21.tlv

  # WIFI
  # TODO: what about "bdwlan-blueline.bin" from the vendor-fw?
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/wlanmdsp.mbn
  (
    d="$(mktemp -d)"
  )
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/XXXX/bdwlan.FOO
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/XXXX/firmware-5.bin
  (
    cd "$fw_qca_p3"
    "${ath10k-fwencoder}" --modify \
      --features=wowlan,mgmt-tx-by-ref,non-bmi,single-chan-info-per-channel \
      firmware-5.bin      
  )
  cp -vt "$fw_os_ath" ${vendor-firmware-files}/XXXXXXXXXXXX/board-2.bin

  # WIFI REGDB (upstream) ?
  cp -vt "$fw" ${wireless-regdb}/lib/firmware/regulatory.db*
  
  # QUALCOMM IPA (hardware network acceleration)
  (cd ${vendor-firmware-files}/lib/firmware/
    pil-squasher "$fw_qcom_p3/ipa_fws.mbn" ./ipa_fws.mdt
  )

  # MODEM
  (cd ${vendor-firmware-files}/lib/firmware/
    pil-squasher "$fw_qcom_p3/modem.mbn" ./modem.mdt
  )
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/modemr.jsn
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/modemuw.jsn

  # TOUCH SCREEN PANEL
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/ftm5*.ftb
''
