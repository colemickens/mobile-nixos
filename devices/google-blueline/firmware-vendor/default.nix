{ lib
, fetchurl
, runCommandNoCC
, unzip
, e2fsprogs
, mtools
, simg2img
, qc-image-unpacker
}:

let
  upstream = import ./upstream.nix { inherit fetchurl; };
  upstreamImage = upstream.image;
  buildID = upstream.buildID;
in
runCommandNoCC "google-blueline-firmware" {
  version = upstream.buildID;
  nativeBuildInputs = [ unzip e2fsprogs mtools simg2img qc-image-unpacker ];
  meta.license = [
    # We make no claims that it can be redistributed.
    lib.licenses.unfree
  ];
} ''
  unzip ${upstreamImage}

  cd blueline-${buildID}

  # Extract vendor files
  unzip image-blueline-${buildID}.zip vendor.img
  simg2img vendor.img vendor-raw.img
  debugfs vendor-raw.img -R "rdump firmware ."

  # Extract radio files
  qc_image_unpacker -i radio-blueline-*.img
  mcopy -i radio-blueline-*/modem ::/image ./
  mv -vt firmware image/*

  mkdir -p $out/lib
  mv -v firmware $out/lib/firmware
''
