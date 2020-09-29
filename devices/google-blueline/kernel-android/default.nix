{
  mobile-nixos
, fetchFromGitHub
, kernelPatches ? [] # FIXME
, buildPackages
}:

let
  inherit (buildPackages) dtc;
in

(mobile-nixos.kernel-builder-gcc6 {
  configfile = ./config.aarch64;

  file = "Image.gz-dtb";
  hasDTB = true;

  version = "4.9.237";
  src = fetchFromGitHub {
    owner = "android-linux-stable";
    repo = "bluecross";
    rev = "66391b2201b686c9c27ab15d5d3976bf8c322058";
    sha256 = "sha256-ZYYdH2pwEdyMDTbpqXvflXdJDeWeLTfSIR1qIsjuBH8=";
  };

  #patches = [
  #  ./0001-Revert-four-tty-related-commits.patch
  #  ./0003-arch-arm64-Add-config-option-to-fix-bootloader-cmdli.patch
  #  ./99_framebuffer.patch
  #];

  isModular = false;
}).overrideAttrs({ postInstall ? "", postPatch ? "", nativeBuildInputs, ... }: {
  installTargets = [ "zinstall" "Image.gz-dtb" "install" ];
  postPatch = postPatch + ''
    # FIXME : factor out
    (
    # Remove -Werror from all makefiles
    local i
    local makefiles="$(find . -type f -name Makefile)
    $(find . -type f -name Kbuild)"
    for i in $makefiles; do
      sed -i 's/-Werror-/-W/g' "$i"
      sed -i 's/-Werror=/-W/g' "$i"
      sed -i 's/-Werror//g' "$i"
    done
    )

    # Remove google's default dm-verity certs
    rm -f *.x509
  '';
  nativeBuildInputs = nativeBuildInputs ++ [ dtc ];

  postInstall = postInstall + ''
    cp -v "$buildRoot/arch/arm64/boot/Image.gz-dtb" "$out/"
  '';
})
