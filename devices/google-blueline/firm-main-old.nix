{ runCommandNoCC
, firmwareLinuxNonfree
, wireless-regdb
, vendor-firmware-files
}:

# The minimum set of firmware files required for the device.
let
  firmware = vendor-firmware-files;
in runCommandNoCC "google-blueline-firmware" {
  src = firmwareLinuxNonfree;
} ''
  set -xeuo pipefail

  # Firmware from the vendor image
  mkdir -p $out/lib/firmware/qcom/sdm845/blueline

  find ${firmware}

  cp -vt $out/lib/firmware/qcom/sdm845/blueline ${firmware}/lib/firmware/*adsp*
  cp -vt $out/lib/firmware/qcom/sdm845/blueline ${firmware}/lib/firmware/*cdsp*

  # IPA FW
  # see: #mainline-sdm845:connolly.tech/$yUu3q7MahaDr7OIrVD_DWXOUb2sj85YAo4_KnJfyNJU => #mainline-sdm845:connolly.tech/$QkomPlPjkkouKDlg8EZ1R-znZtZJNiHNOhifZd2jDHg
  cp -vt $out/lib/firmware/qcom/sdm845/blueline ${firmware}/lib/firmware/*ipa_fws*

  # GPU (mainly)
  cp -vt $out/lib/firmware/qcom/sdm845/blueline ${firmware}/lib/firmware/*a630*

  # Modem stuff
  cp -vt $out/lib/firmware/qcom/sdm845/blueline ${firmware}/lib/firmware/*mba*
  cp -vt $out/lib/firmware/qcom/sdm845/blueline ${firmware}/lib/firmware/*modem*

  # ?? see: https://gitlab.com/sdm845-mainline/firmware-oneplus-sdm845/-/tree/prepackaged-release/lib/firmware/qcom/sdm845/oneplus6
  cp -vt $out/lib/firmware/qcom/sdm845/blueline ${firmware}/lib/firmware/*slp*
  cp -vt $out/lib/firmware/qcom/sdm845/blueline ${firmware}/lib/firmware/*venus*

  # Touch panel
  cp -vt $out/lib/firmware/ ${firmware}/lib/firmware/ftm5*.ftb

  (
    cd $out/lib/firmware/qcom
    for f in sdm845/blueline/*; do
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
