{ config, lib, pkgs, impermanence, secrets, ... }:

{
  imports = [
      ../../crumbs/base.nix
      ../../crumbs/locale.nix
      ../../crumbs/desktop.nix
      ../../crumbs/networkd.nix
      ../../crumbs/sshd.nix

      ../../users/oxy/user.nix
      ../../users/oxy/desktop.nix

      ./hardware-configuration.nix
    ];

  # hostname
  networking.hostName = "carmine";

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  users.users.oxy.hashedPassword = lib.fileContents ${secrets}/carmine/oxy.pwd;
  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.11";
}
