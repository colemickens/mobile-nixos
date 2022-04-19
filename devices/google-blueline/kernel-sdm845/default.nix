{ mobile-nixos
, fetchFromGitLab
, fetchpatch
, runCommandNoCC
, lib
, ...
}:

let
  k845 = mobile-nixos.kernel-builder rec {
    # https://gitlab.com/sdm845-mainline/linux/-/tree/sdm845/5.18-dev
    version = "5.17.0";
    modDirVersion = "5.17.0";
    configfile = ./config.aarch64;
    src = fetchFromGitLab {
      owner = "sdm845-mainline";
      repo = "linux";
      rev = "452e02d876234a43cfd9256134ad115b3674e47c";
      sha256 = "sha256-1fp3zH8WG7RGd7C58HX+LVI+8qpeDwxDmmePVpUQ4ls=";
    };

    patches = [
    ];

    postInstall = ''
      echo ':: Copying kernel'
      (PS4=" $ "; set -x
      cp -v \
        $buildRoot/arch/arm64/boot/Image.${isCompressed} \
        $out/
      )
    '';

    isModular = false;
    isCompressed = "gz";
    kernelFile = "Image.${isCompressed}";
  };
  appendDtb = device: rawkernel: dtb: 
    (runCommandNoCC "${device}-kernel-dtb"
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
in
{
  tools = { inherit appendDtb; };
  kernels = lib.genAttrs
    [ "google-blueline" "oneplus-enchilada" ]
    (d: (appendDtb d k845 "${k845}/dtbs/qcom/sdm845-${d}.dtb"))
  ;
}
