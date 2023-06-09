{ config, lib, pkgs, ... }:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "mode=0755" "size=256M" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/nixos-boot";
    fsType = "vfat";
    options = [ "noexec" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-partlabel/nixos";
    fsType = "ext4";
  };
  
  fileSystems."/srv/nas" = {
    device = "/dev/disk/by-partlabel/nas-4t";
    fsType = "btrfs";
    options = [ "noexec" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  services.thermald.enable = lib.mkDefault true;
  
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  hardware.firmware = with pkgs; [
    sof-firmware
    linux-firmware
  ];
}
