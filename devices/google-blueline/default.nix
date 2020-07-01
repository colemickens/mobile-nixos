{ config, lib, pkgs, ... }:


# +dtb-$(CONFIG_ARCH_QCOM)	+= sdm845-blueline.dtb # https://git.linaro.org/people/sumit.semwal/linux-dev.git/commit/?h=dev/p3-mainline-5.8-rc3&id=87ad00791b7f2c346ad0fe0caaa4ee3ff9980374

{
  mobile.device.name = "google-blueline";
  mobile.device.identity = {
    name = "Google Pixel 3";
    manufacturer = "Google";
  };

  mobile.hardware = {
    soc = "qualcomm-sdm845";
    #soc = "qualcomm-sdm845";
    ram = 1024 * 4;
    screen = {
      width = 2280; height = 1080;
    };
  };

  mobile.boot.stage-1 = {
    kernel.package = pkgs.callPackage ./kernel {
      kernelPatches = pkgs.defaultKernelPatches;
    };
  };

  mobile.system.android = {
    # This device has an A/B partition scheme
    ab_partitions = true;

    bootimg.flash = {
      offset_base = "0x80000000";
      offset_kernel = "0x00008000";
      offset_ramdisk = "0x01000000";
      offset_second = "0x00f00000";
      offset_tags = "0x00000100";
      pagesize = "4096";
    };
  };

  mobile.system.vendor.partition = "/dev/disk/by-partlabel/vendor_a";

  boot.kernelParams = [
    "console=ttyHSL0,115200,n8"
    "androidboot.console=ttyHSL0"
    "androidboot.hardware=marlin"
    "user_debug=31"
    "ehci-hcd.park=3"
    "lpm_levels.sleep_disabled=1"
    "cma=32M@0-0xffffffff"
    "loop.max_part=7"
    "buildvariant=eng"
    "firmware_class.path=/vendor/firmware"
  ];

  mobile.usb.mode = "android_usb";
  # Google
  mobile.usb.idVendor = "18D1";
  # "Pixel" rndis+adb
  mobile.usb.idProduct = "4EE4";

  mobile.system.type = "android";
}
