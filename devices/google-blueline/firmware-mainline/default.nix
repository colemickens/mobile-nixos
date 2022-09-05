{ runCommandNoCC, fetchurl
, lib
, firmwareLinuxNonfree
, mobile-nixos
, wireless-regdb
, vendor-firmware-files

, pil-squasher
, qca-swiss-army-knife

, firmware_class_name ? "mobile-nixos" # TODO: plumb in
}:

let
  firmware_class_path = "mobile-nixos"; # TODO do the kernel param side
  ath10k_firmware5bin_hl20 = fetchurl {
    name = "firmware-5.bin";
    url = "https://raw.githubusercontent.com/kvalo/ath10k-firmware/master/WCN3990/hw1.0/HL2.0/WLAN.HL.2.0-01387-QCAHLSWMTPLZ-1/firmware-5.bin";
    sha256 = "sha256-/vZTngEnV5U2vJd75XqQ0Bi4Pykx/tw6iHD7441sQSc=";
  };
  # TODO: worth trying hl31 ? ask caleb?
  # https://github.com/kvalo/ath10k-firmware/tree/master/WCN3990/hw1.0/HL3.1
  # ath10k_firmware5bin_hl31 = pkgs.fetchurl {
  #   url = "";
  #   sha256 = lib.fakeSha256;
  # };
in
  
# The minimum set of firmware files required for the device.
runCommandNoCC "google-blueline-firmware" {
  version = vendor-firmware-files.version;
  src = firmwareLinuxNonfree;
  nativeBuildInputs = [ pil-squasher qca-swiss-army-knife ];
  meta.license = [ lib.licenses.unfree ];
} ''
  echo $PATH
  # Firmware from the vendor image
    
  ## layout notes:
  ## following postmarketos (or at least sdm845-mainline):
  
  ## huge thank you to Caleb from PMOS for the (sometimes kindly repeated) help
  ## and pointers! and of course the folks in all the blueline/kernel commits :D

  ## explainer: https://matrix.to/#/!xgUMIsYnSIXklwbhrG:postmarketos.org/$FvogeaBt4OnHmr5AhVskbSdm8bQ7GG28ztr7ajeGux4
  ## ref: https://gitlab.com/sdm845-mainline/pmaports/-/blob/9903b9539ed957de45d6fbde37c4b74fac5ae711/device/testing/firmware-google-pixel3/30-gpu-firmware.files
  ## ref: https://gitlab.com/sdm845-mainline/pmaports/-/blob/9903b9539ed957de45d6fbde37c4b74fac5ae711/device/testing/firmware-google-pixel3/firmware.files

  fw="$out/lib/firmware"
  fw_qcom="$out/lib/firmware/qcom"
  fw_qcom_p3="$out/lib/firmware/qcom/sdm845/pixel3"
  fw_qca_p3="$out/lib/firmware/qca/pixel3"
  mkdir -p $fwqcom $fw_qcom_p3 $fw_qca_p3

  fw_os="$out/lib/firmware/${firmware_class_name}"
  fw_os_ath="''${fw_os}/ath10k/WCN3900/hw1.0/"
  fw_os_qca="''${fw_os}/qca"
  mkdir -p $fw_os_qca $fw_os_ath
  
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
  # TODO: qdsp6m.qdb  from vendor-fw?
  # TODO:
  # SLPI - slpi.mdt - "low power island" "sensor DSP"

  # ADSP/CDSP = Qualcomm "application DSP" (Compute DSP) + Audio DSP
  (cd ${vendor-firmware-files}/lib/firmware/
    pil-squasher "$fw_qcom_p3/adsp.mbn" ./adsp.mdt
    pil-squasher "$fw_qcom_p3/cdsp.mbn" ./cdsp.mdt
  )
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/*adsp*.{mbn,jsn}
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/*cdsp*.{mbn,jsn}
    
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
  # TODO: re: pmos: upstream has firmware-5.bin and wlanmdsp.mbn in hw1.0/
  # https://github.com/jhugo/linux/blob/5.5rc2_wifi/README#L10=
  # via: https://wiki.postmarketos.org/wiki/Qualcomm_Snapdragon_835_(MSM8998)#WLAN
  # cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/bdwlan-blueline.bin
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/wlanmdsp.mbn
  cp -v "${vendor-firmware-files}/lib/firmware/bdwlan-blueline.bin" "''${fw_qcom_p3}/bdwlan.bin"
  cp -v "${ath10k_firmware5bin_hl20}" "''${fw_qcom_p3}/firmware-5.bin"
  chmod +w "''${fw_qcom_p3}/firmware-5.bin" # ath10k-fwencoder modifies it
  (
    cd $fw_qcom_p3;
    qca-gen-boardbin
    mv $fw_qcom_p3/firmware-5.bin $fw_os_ath/
    mv $fw_qcom_p3/board-2.bin $fw_os_ath/
  )
  ath10k-fwencoder --modify \
    --features=wowlan,mgmt-tx-by-ref,non-bmi,single-chan-info-per-channel \
    "$fw_os_ath/firmware-5.bin"

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
    
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/modem.mdt
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/modem.b*

  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/mba.mbn
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/modemr.jsn
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/modemuw.jsn

  # TOUCH SCREEN PANEL
  cp -vt "$fw_qcom_p3" ${vendor-firmware-files}/lib/firmware/ftm5*.ftb
''
