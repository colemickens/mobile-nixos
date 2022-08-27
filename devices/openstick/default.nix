{ config, lib, pkgs, ... }:

# TODO: most of this hasn't been updated, etc

let
  openstick_lk2nd = pkgs.lk2ndMsm8913openstick;
in
{
  mobile.device.name = "openstick";
  mobile.device.identity = {
    name = "openstick";
    manufacturer = "aliexpress"; # lol
  };

  mobile.hardware = {
    soc = "qualcomm-msm8916";
    # TODO: these aren't right:
    ram = 1024 * 4;
    screen = {
      width = 1440; height = 2880;
    };
  };

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel { };
    bootlog.enable = false;
    crashToBootloader = true;
  };

  mobile.device.firmware = pkgs.callPackage ./firmware {};
  mobile.boot.stage-1.firmware = [
    config.mobile.device.firmware
  ];
  
  mobile.outputs.android.android-abootimg = (
    pkgs.runCommand "emmc_appsboot-test-signed.mbn"
    { nativeBuildInputs = [ pkgs.qtestsign ]; }
    ''
      tmp="''$(mktemp -d)"
      cp ${openstick_lk2nd.out}/emmc_appsboot.mbn $tmp/
      qtestsign.py aboot $tmp/emmc_appsboot.mbn
      mv $tmp/emmc_appsboot-test-signed.mbn $out
    ''
  );

  # mobile.adbd.enable = false;
  mobile.boot.stage-1.usb.enable = false;

  systemd.packages = [ pkgs.rmtfs pkgs.qrtr ];

  mobile.system.system = "aarch64-linux";
  mobile.system.android.device_name = "openstick";
  mobile.system.android = {
    ab_partitions = false;

    bootimg.flash = {
      offset_base = "0x80078000";
      offset_kernel = "0x00008000";
      offset_ramdisk = "0x01f88000";
      offset_second = "0x7ff88000";
      offset_tags = "0x01d88000";
      pagesize = "2048";
    };
  };

  # mobile.system.vendor.partition = "/dev/disk/by-partlabel/rootfs";

  boot.kernelParams = [
    "earlycon"
    "console=ttyMSM0,115200"
  ];

  # TODO
  mobile.usb.mode = "android_usb";
  mobile.usb.idVendor = "18D1";
  mobile.usb.idProduct = "4EE4";
  mobile.system.type = "android";

  # mobile.quirks.qualcomm.wcnss-wlan.enable = true;
  mobile.quirks.wifi.disableMacAddressRandomization = true;
}
