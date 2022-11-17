{ mobile-nixos
, fetchFromGitLab
, ...
}:

mobile-nixos.kernel-builder rec {
  version = "6.0.0";
  modDirVersion = "6.0.0-next-20221013";
  configfile = ./config.aarch64;

  src = fetchFromGitLab {
    owner = "sdm845-mainline";
    repo = "linux";
    rev = "a2120bf36eec94b95796f3ccb2d2c4680aeee356"; # XXX WIP
    hash = "sha256-CTZXzaijsPYHzs6v3feG0IJcCDeKSmvDgJhbuZn/9UE=";
  };

  patches = [
    # ./0001-XXX-google-blueline-sync-dts-with-9060b7256952a63311.patch
    # ./0001-touchscreen-focaltech_fts-Add-missing-include.patch
  ];

  isModular = false;
  isCompressed = "gz";
}
