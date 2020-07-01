{
  mobile-nixos
, fetchgit
, kernelPatches ? [] # FIXME
, buildPackages
}:

let
  inherit (buildPackages) dtc;
  src = fetchgit {
    url = "https://git.linaro.org/people/sumit.semwal/linux-dev.git";
    # rev = "dev/p3-mainline-5.8-rc3";
    rev = "a22d8fbd644c846e4db3112634d8a0b196a2922d";
    sha256 = "02jj6zxkxx6cynq0rdq4249ns8wwwkybpdkp6gsi7v0y8czfdajj";
  };
in

(mobile-nixos.kernel-builder-gcc6 {
  configfile = "${src}/arch/arm64/configs/blueline_defconfig"; 

  file = "Image.gz-dtb";
  hasDTB = true;

  version = "5.8-rc3";
  src = src;

  isModular = false; # TODO ???

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
