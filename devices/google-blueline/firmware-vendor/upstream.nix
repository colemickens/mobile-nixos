{ fetchurl }:

let
  # https://dl.google.com/dl/android/aosp/blueline-rq3a.210605.005-factory-53820251.zip
in rec {
  buildID = "rq3a.210605.005";
  url = "https://dl.google.com/dl/android/aosp/blueline-${buildID}-factory-53820251.zip";
  image = fetchurl {
    inherit url;
    sha256 = "17l4b5gs8g182czl3zyvs8kydb6w23hbwkd2m9ngy7wfym8h50jk";
  };
}
