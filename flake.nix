{
  description = "mobile-nixos";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
  };

  outputs = inputs:
    let
    in {
      mkDevice = deviceName: (import ./default.nix {
        device = deviceName;
        pkgs = inputs.nixpkgs;
      }).config.system.build.toplevel;

      nixosModules = import ./modules/module-list.nix;

      devices = {
        pine64-pinephone = import ./devices/pine64-pinephone-braveheart;
      };
    };
}

