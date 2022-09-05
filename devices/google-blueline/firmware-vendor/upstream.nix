{ fetchurl }:

let
  # https://dl.google.com/dl/android/aosp/blueline-rq3a.210605.005-factory-53820251.zip
in rec {
  # buildID = "rq3a.210605.005"; # huh, thought they were done...
  buildID = "sp1a.210812.016.c2";
  buildTag = "fa981d87";
  url = "https://dl.google.com/dl/android/aosp/blueline-${buildID}-factory-${buildTag}.zip";
  image = fetchurl {
    inherit url;
    sha256 = "sha256-+pgdh7ayihmWFhrMuxR/Rv4pZjuyzmzBPcnlAMvFnJM=";
  };
}
