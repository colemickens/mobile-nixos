{ mobile-nixos
, fetchFromGitLab
, fetchpatch
, runCommandNoCC
, lib
, ...
}:

device: rawkernel: dtb:
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
    '')
