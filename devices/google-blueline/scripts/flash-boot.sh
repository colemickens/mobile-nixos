#!/usr/bin/env bash

set -euo pipefail
set -x

if ! which fastboot; then echo "fastboot missing"; exit -1; fi
if ! which zstd; then echo "fastboot missing"; exit -1; fi
temp="$(mktemp -d)"; mkdir -p "${temp}"; trap "rm -rf ${temp}" EXIT;

export bootfs_dest="@bootfs_dest@"
export bootfs_zstd="@bootfs_zstd@"
export firmware="@firmware@"

zstdcat "${bootfs_zstd}" > "${temp}/boot.img"
fastboot set_active a
fastboot flash --slot a "${bootfs_dest}" "${temp}/boot.img"
fastboot erase dtbo
fastboot set_active a
fastboot reboot bootloader
