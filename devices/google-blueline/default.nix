{ config, pkgs, lib, ... }:

let
  zstdify = f: builtins.trace f pkgs.runCommandNoCC "${builtins.baseNameOf f}.zstd"
    {nativeBuildInputs=[pkgs.zstd];}
  ''
    set -x
    zstd "${f}" -o $out
  '';

  firmware_class_path = "mobile-nixos";
  
  # flashScript = p: args: pkgs.substituteAll ({
  #   name = "flash-${p}.sh";
  #   src = ./. + "/scripts/flash-${p}.sh";
  #   isExecutable = true;
  # } // (builtins.trace args args));

  # TODO: https://www.spinics.net/lists/linux-bluetooth/msg93561.html
  
  sdm845 = pkgs.callPackage ./kernel-sdm845 {};
  
  kernel_mainline = pkgs.callPackage ./kernel-mainline { };
  kernel_mainparts = pkgs.callPackage ./kernel-mainline {
    sdm845 = sdm845;
  };
in {
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
    boot_as_recovery = true;

    bootimg.flash = {
      offset_base = "0x00000000";
      offset_kernel = "0x00008000";
      offset_ramdisk = "0x01000000";
      offset_second = "0x00000000";
      offset_tags = "0x00000100";
      pagesize = "4096";
    };
  };
  
  # system.build.flash-boot = flashScript "boot" {
  #   bootfs_zstd = zstdify config.mobile.outputs.android.android-bootimg.outPath;
  #   bootfs_dest = config.mobile.system.android.boot_partition_destination;
  #   firmware = config.mobile.device.firmware;
  # };
  # system.build.flash-system = flashScript "system" {
  #   rootfs_zstd = zstdify (let r=config.mobile.outputs.generatedFilesystems.rootfs; in "${r}/${r.filename}");
  #   rootfs_dest = config.mobile.system.android.system_partition_destination;
  # };

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = lib.mkBefore [ config.mobile.device.firmware ];

  # option 1: generic kernel + dtb->mkbootimg
  # TODO: the sdm845 kernel doesnt have blueline yet:
  # mobile.boot.stage-1.kernel.package = kernel_sdm845;
  #TODO: this will change to "sdm845-google-blueline.dtb"
  # mobile.system.android.bootimg.dtb = "${kernel_sdm845}/dtbs/qcom/sdm845-blueline.dtb";
    
  # option 2: blueline kernel with dtb appended already (well, its not appened rn)
  # mobile.boot.stage-1.kernel.package = kernel_mainline;

  mobile.boot.stage-1.kernel.package = kernel_mainparts;

  mobile.boot.stage-1 = {
    compression = "xz";
    firmware = lib.mkBefore [
      config.mobile.device.firmware
    ];
  };

  mobile.device.firmware = pkgs.callPackage ./firmware-mainline {
    vendor-firmware-files = pkgs.callPackage ./firmware-vendor { };
  };

  boot.kernelParams = [
    # Extracted from an Android boot image
    "console=ttyMSM0,115200n8"
    "printk.devkmsg=on"
    "firmware_class.path=${firmware_class_path}"
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

  mobile.quirks.qualcomm.sdm845-modem.enable = true;

  mobile.system.android.system_partition_destination = "userdata";
}
