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

  version = "5.15.0"; # -msm8916";
  src = fetchFromGitHub {
    # owner = "OpenStick";
    owner = "colemickens";
    repo = "linux";
    rev = "19d30bdbf3aeecbbec0a81217f19cbf0318f273b";
    # rev = "3b1d3bfb978fb2be6707d033f26205104d60c92f";
    sha256 = "sha256-mp+QjfmAuoAc7P/r2njfcLZCVnuBqvF4V8MrRXy5Dn0=";
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
