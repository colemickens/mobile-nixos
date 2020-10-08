{ pkgs, ... }:

/*
 * This file has been generated by autoport.
 * **Do not** open a Pull Request without having verified the port works.
 */
 let 
  kernelMainline = pkgs.callPackage ./kernel-mainline {
    kernelPatches = pkgs.defaultKernelPatches;
  };
  kernelALS = pkgs.callPackage ./kernel-als {
    kernelPatches = pkgs.defaultKernelPatches;
  };
  kernelPMOS = pkgs.callPackage ./kernel-lineageos {
    kernelPatches = pkgs.defaultKernelPatches;
  };
  activeKernel =
    #kernelMainline;
    kernelALS;
    #kernelPMOS;

  firmware = pkgs.callPackage ./firmware {};
in
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
      width = 2280; height = 1080;
    };
  };

  mobile.boot.stage-1 = {
    kernel.package = activeKernel;
  };

  mobile.system.android = {
    # This device has an A/B partition scheme.
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

  # TODO: revisit; requires support for dynamic partitions
  #mobile.system.vendor.partition = "/dev/disk/by-partlabel/vendor_a";

  mobile.device.firmware = firmware;
  mobile.boot.stage-1.firmware = [ firmware ];
  
  boot.kernelParams = [
    # Extracted from an Android boot image
    "console=ttyMSM0,115200n8"
    "androidboot.console=ttyMSM0"
    "printk.devkmsg=on"
    "msm_rtb.filter=0x237"
    "ehci-hcd.park=3"
    "service_locator.enable=1"
    "cgroup.memory=nokmem"
    "lpm_levels.sleep_disabled=1"
    "usbcore.autosuspend=7"
    "loop.max_part=7"
    "androidboot.boot_devices=soc/1d84000.ufshc"
    "androidboot.super_partition=system"
    "buildvariant=user"
  ];

  mobile.system.type = "android";

  mobile.usb.mode = "gadgetfs";

  /* To be changed by the author, though those may or may work with any device. */
  # Google
  mobile.usb.idVendor = "18D1";
  # source: https://git.rip/dumps/google/blueline/-/blob/blueline-user-11-RPB3.200720.005-6705141-release-keys/bootimg/ramdisk/system/etc/init/hw/init.rc#L132-178
  mobile.usb.idProduct = "D001";

  mobile.usb.gadgetfs.functions = {
    rndis = "gsi.rndis";
  };
}
