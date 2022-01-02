{ config, pkgs, ... }:

{
  mobile.device.name = "google-blueline";
  mobile.device.identity = {
    name = "Pixel 3";
    manufacturer = "Google";
  };

  mobile.hardware = {
    soc = "qualcomm-sdm845";
    ram = 1024 * 4;
    screen = {
      width = 1080; height = 2160;
    };
  };

  mobile.system.android.device_name = "blueline";
  mobile.system.android = {
    # This device has an A/B partition scheme.
    # NOTE: while A/B, we cannot rely on anything else than `boot` as this
    #       device uses dynamic partitions.
    ab_partitions = true;

    bootimg.flash = {
      offset_base = "0x00000000";
      offset_kernel = "0x00008000";
      offset_ramdisk = "0x01000000";
      offset_second = "0x00000000";
      offset_tags = "0x00000100";
      pagesize = "4096";
    };
  };

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel-mainline { };
    compression = "xz";
  };

  mobile.device.firmware = pkgs.callPackage ./firmware-mainline {
    vendor-firmware-files = pkgs.callPackage ./firmware-vendor { };
  };

  mobile.boot.stage-1.firmware = [
    config.mobile.device.firmware
  ];

  boot.kernelParams = [
    # Extracted from an Android boot image
    "console=ttyMSM0,115200n8"
    "printk.devkmsg=on"
  ];

  mobile.system.type = "android";

  mobile.usb.mode = "gadgetfs";

  # Google
  mobile.usb.idVendor = "18D1";
  # "Nexus 4"
  mobile.usb.idProduct = "D001";

  mobile.usb.gadgetfs.functions = {
    adb = "ffs.adb";
    rndis = "rndis.usb0";
  };
  mobile.system.android.system_partition_destination = "userdata";
}
