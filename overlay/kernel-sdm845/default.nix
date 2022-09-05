{ mobile-nixos
# , fetchFromGitLab
, fetchFromGitHub
, fetchpatch
, runCommandNoCC
, lib
, ...
}:

mobile-nixos.kernel-builder rec {
  # https://gitlab.com/sdm845-mainline/linux/-/tree/sdm845/5.18-dev
  version = "5.19.0";
  modDirVersion = "5.19.0-rc1";
  configfile = ./config.aarch64;
  # src = fetchFromGitLab {
  #   owner = "sdm845-mainline";
  #   repo = "linux";
  src = fetchFromGitHub {
    owner = "colemickens";
    repo = "linux";
    rev = "994f62a7dbc9891e8b070e3f871efb805472f057";
    sha256 = "sha256-BuPEzEzF5row9ybwQ0OTx2m9u8n6y+l4LGNC0/YLEW0=";
  };

   patches = [
     ./remoteproc_fw_names.patch
  ];

  postInstall = ''
    echo ':: Copying kernel'
     (PS4=" $ "; set -x
     cp -v \
      $buildRoot/arch/arm64/boot/Image.${isCompressed} \
      $out/
    )
  '';

  isModular = true;
  isCompressed = "gz";
  kernelFile = "Image.${isCompressed}";
}
