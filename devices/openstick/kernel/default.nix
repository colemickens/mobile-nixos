{
  mobile-nixos
, runCommand
, fetchFromGitHub
, ...
}:

let

  appendDtb = device: rawkernel: dtb: 
    (runCommand "${device}-kernel-dtb"
    {
      version = rawkernel.version;
      passthru =
        let
          rwp = rawkernel.passthru;
          p = (rwp // {
            file = "Image.${rawkernel.isCompressed}-dtb";
          });
        in p;
    }
    ''
      echo ':: Appending DTB'
      (PS4=" $ "; set -x
      cp -r ${rawkernel} $out
      chmod +w $out
      cat \
        ${rawkernel}/Image.${rawkernel.isCompressed} \
        ${dtb} \
        > $out/Image.${rawkernel.isCompressed}-dtb
      )
    '');

vk = mobile-nixos.kernel-builder-gcc6 rec {
  configfile = ./config.aarch64;

  version = "5.15.13"; # -msm8916";
  src = fetchFromGitHub {
    # owner = "OpenStick";
    owner = "colemickens";
    repo = "linux";
    rev = "d7635fe5da2b774fc7a21f94519c00a5cf1abb1e";
    hash = "sha256-kcEAq3AXLw6MoG91xC1iPFTviQUYNldmGkb1RATHeQQ=";
  };

  patches = [
    # ./0001-Revert-four-tty-related-commits.patch
    ./0003-arch-arm64-Add-config-option-to-fix-bootloader-cmdli.patch
    # ./99_framebuffer.patch
  ];
  hasDTB = true;

  enableRemovingWerror = true;
  isCompressed = "gz";
  kernelFile = "Image.${isCompressed}-dtb";
  # isModular = false; #???
  isModular = true;
};

in
 (appendDtb "openstick" vk "${vk}/dtbs/qcom/msm8916-handsome-openstick-uf896-v1_1.dtb")
