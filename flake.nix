{
  description = "mobile-nixos";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
  };

  outputs = inputs:
    let
    in {
      mkDevice = import ./default.nix { nixpkgs = inputs.nixpkgs.legacyPackages."x86_64-linux"; };
    };
}

