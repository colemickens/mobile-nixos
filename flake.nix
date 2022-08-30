{
  description = "mobile-nixos";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-compat }@inputs:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = genAttrs supportedSystems;

      devices = builtins.filter
        (device: builtins.pathExists (./. + "/devices/${device}/default.nix"))
        (builtins.attrNames (builtins.readDir ./devices));

      mkDeviceModule = device: {
        name = device;
        value = (import ./lib/configuration.nix { inherit device; });
      };

    in {
      inputs = inputs;
      
      devShell = forAllSystems (s: import ./shell.nix { pkgs = import nixpkgs { system = s; }; });

      overlay = final: prev: (self.overlays.default final prev) // (self.overlays.mruby-builder final prev);

      packages = forAllSystems (s: 
        let
          nixpkgs = import inputs.nixpkgs { system = s; overlays = [self.overlay ]; };
        in self.overlays.default nixpkgs nixpkgs
      );
      
      overlays = {
        default = import ./overlay/overlay.nix;
        mruby-builder = import ./overlay/mruby-builder/overlay.nix;
      };

      nixosModules = builtins.listToAttrs (builtins.map mkDeviceModule devices);
    };
}
