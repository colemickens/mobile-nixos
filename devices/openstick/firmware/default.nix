{ lib
, runCommand
, fetchurl
, e2fsprogs
, mtools
, linux-firmware
}:

let
  modemImage = fetchurl {
    url = "https://github.com/Informatic/stick-blobs/raw/abdf16d3aa2e415c6c41062a5e2575cdc7b70fd8/stock-uf896_v1_1/modem.bin";
    sha256 = "sha256-LB5nwSbVTxPgFb+a+NcSgx3F6SC1FJX1IVc7bLIWNXM=";
  };
  wlannvImage = fetchurl {
    url = "https://github.com/Informatic/stick-blobs/raw/abdf16d3aa2e415c6c41062a5e2575cdc7b70fd8/stock-uf896_v1_1/persist.bin";
    sha256 = "sha256-3xW6e0eKEpeR1Nz4uQGG0BIWzEVq/o7jtpSZvgRIiX0=";
  };
in runCommandNoCC "openstick-firmware" {
  nativeBuildInputs = [ e2fsprogs mtools ];
  meta.license = [
    # We make no claims that it can be redistributed.
    lib.licenses.unfree
  ];
} ''
  mkdir -p $out/lib/firmware/wlan/prima/
  debugfs ${wlannvImage} -R "rdump WCNSS_qcom_wlan_nv.bin $out/lib/firmware/wlan/prima/"

  mcopy -v -s -i ${modemImage} '::image/modem.*' '::image/mba.*' '::image/wcnss.*' $out/lib/firmware/

  mkdir -p $out/lib/firmware/qcom/
  cp -r ${linux-firmware}/lib/firmware/qcom/{venus-1.8,a300_pfp.fw,a300_pm4.fw} $out/lib/firmware/qcom/

  ls -al -R $out/lib/firmware
''
