#!/usr/bin/env bash

set -euo pipefail
set -x

export ROOTFS_DEST="@@ROOTFS_DEST@@"
export BOOTFS_DEST="@@BOOTFS_DEST@@"

export VENDOR_ZSTD="@@VENDOR_ZSTD@@"
export BOOTFS_ZSTD="@@BOOTFS_ZSTD@@"
export ROOTFS_ZSTD="@@ROOTFS_ZSTD@@"

if ! which fastboot; then echo "fastboot missing"; exit -1; fi
if ! which zstd; then echo "fastboot missing"; exit -1; fi

# be careful this is fine for now since its cleaned between invocations, otherwise boot.img could clash
temp="$(mktemp -d)"; mkdir -p "${temp}"; trap "rm -rf ${temp}" EXIT;

case "${1}" in
  "factory-critical")
    tar xvf "${VENDOR_ZSTD}" -C "${temp}"
    fastboot reboot bootloader
    fastboot flash radio      --slot all "${temp}/radio.img"
    fastboot flash bootloader --slot all "${temp}/bootloader.img"
    fastboot flash boot       --slot all "${temp}/boot.img"
    fastboot flash dtbo       --slot all "${temp}/dtbo.img"
    fastboot flash vbmeta     --slot all "${temp}/vbmeta.img"
    fastboot reboot fastboot
    fastboot flash vendor --slot all "${temp}/vendor.img"
    fastboot reboot bootloader
  ;;
  "boot")
    tar xvf "${BOOTFS_ZSTD}" -C "${temp}"
    fastboot set_active a
    fastboot flash --slot a "${BOOTFS_DEST}" "${temp}/boot.img"
    fastboot erase dtbo
    fastboot set_active a
    fastboot reboot
  ;;
  "system")
    tar xvf "${ROOTFS_ZSTD}" -C "${temp}"
    # fastboot reboot fastboot
    # fastboot set_active a
    # fastboot flash --slot a "${dest}" "${img}"
    # fastboot set_active a
    # fastboot reboot bootloader

    # for now we know we're flashing userdata
    # and we know we can flash uni-slot
    # userdata from fastboot
    fastboot flash "${ROOTFS_DEST}" "${temp}/rootfs.img"
  ;;
  "factory-reset")
    echo "not implemented"
    exit -1
  ;;
esac
