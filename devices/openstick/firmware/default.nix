{ lib
, runCommand
, fetchurl
, fetchgit
, unzip
, e2fsprogs
, simg2img
}:

let
  upstreamImage = fetchurl {
    url = "https://github.com/OpenStick/OpenStick/releases/download/v1/debian.zip";
    sha256 = "sha256-i+bxAOj8P2EuCwPBmdAfUdOLlToZNDrQ9M96L3pX9gM=";
  };
in runCommand "openstick-firmware" {
  nativeBuildInputs = [ e2fsprogs mtools unzip simg2img];
  meta.license = [
    # We make no claims that it can be redistributed.
    lib.licenses.unfree
  ];
} ''
  unzip ${upstreamImage} debian/rootfs.img
  cd debian
  simg2img rootfs.img vendor-raw.img
  debugfs vendor-raw.img -R "rdump lib/firmware ."
  
  ls -al -R .

  mkdir -p $out/lib
  mv firmware $out/lib/firmware
  
  echo "--"
  ls -al $out/lib/firmware
  # exit -1
''
