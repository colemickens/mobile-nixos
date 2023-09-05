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

      deviceNames = builtins.filter
        (device: builtins.pathExists (./. + "/devices/${device}/default.nix"))
        (builtins.attrNames (builtins.readDir ./devices));

      mkDeviceModule = device: {
        name = device;
        # value = (import ./lib/configuration.nix { inherit device; });
        value = ({...}: {
          imports = [ ./devices/${device}/default.nix ]
            ++ (import ./modules/module-list.nix);
        });
      };

      nixosModules = {
        devices = builtins.listToAttrs (builtins.map mkDeviceModule deviceNames);
      };
      
    in rec {
      inherit inputs nixosModules;
      
      # devShell = forAllSystems (s: import ./shell.nix { pkgs = import nixpkgs { system = s; }; });

      overlay = final: prev: (self.overlays.default final prev) // (self.overlays.mruby-builder final prev);

      # packages = forAllSystems (s: 
      #   let
      #     nixpkgs = import inputs.nixpkgs {
      #       hostPlatform.system = s;
      #       overlays = [self.overlay ];
      #     };
      #   in self.overlays.default nixpkgs nixpkgs
      # );
      
      overlays = {
        default = import ./overlay/overlay.nix;
        mruby-builder = import ./overlay/mruby-builder/overlay.nix;
      };

      devices = genAttrs deviceNames (d: {
        example = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            (nixosModules.devices.${d})
            { nixpkgs.hostPlatform.system = "aarch64-linux"; }
          ];
        };
      });
    };
}
