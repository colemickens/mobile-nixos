{ config, lib, pkgs, modulesPath, ... }:

let
  ifSystem = type: lib.mkIf (config.mobile.system.type == type);
in
{
  imports = [
    "${modulesPath}/profiles/installation-device.nix"
  ];

  config = lib.mkMerge [
    {
      # This seems counter-intuitive to me, but networkmanager requires that
      # this is set to false.
      networking.wireless.enable = false;
      networking.networkmanager.enable = true;
    }
    (ifSystem "depthcharge" {
      environment.systemPackages = with pkgs; [
        vboot_reference
      ];
    })
  ];
}
