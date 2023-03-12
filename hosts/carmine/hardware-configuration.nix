{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "mode=0755" "size=256M" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/nixos-boot";
    fsType = "vfat";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-partlabel/nixos";
    fsType = "ext4";
  };
  
  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  hardware.parallels.enable = true;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "prl-tools" ];
}
