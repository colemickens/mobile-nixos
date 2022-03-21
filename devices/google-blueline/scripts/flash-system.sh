#!/usr/bin/env bash

set -euo pipefail
set -x

if ! which fastboot; then echo "fastboot missing"; exit -1; fi
if ! which zstd; then echo "fastboot missing"; exit -1; fi
temp="$(mktemp -d)"; mkdir -p "${temp}"; trap "rm -rf ${temp}" EXIT;

export rootfs_dest="@rootfs_dest@"
export rootfs_zstd="@rootfs_zstd@"

zstdcat "${rootfs_zstd}" > "${temp}/rootfs.img"
# fastboot reboot fastboot
# fastboot set_active a
# fastboot flash --slot a "${dest}" "${img}"
# fastboot set_active a
# fastboot reboot bootloader

# for now we know we're flashing userdata
# and we know we can flash uni-slot
# userdata from fastboot
fastboot flash "${rootfs_dest}" "${temp}/rootfs.img"
fastboot reboot
