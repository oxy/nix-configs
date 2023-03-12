{ config, lib, pkgs, impermanence, secrets, ... }:

{
  imports = [
      ../../crumbs/base.nix
      ../../crumbs/locale.nix
      ../../crumbs/desktop.nix
      ../../crumbs/networkd.nix
      ../../crumbs/sshd.nix

      ../../users/oxy.nix

      ./hardware-configuration.nix
    ];

  # hostname
  networking.hostName = "carmine";

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # passwordless machine
  users.users.oxy.hashedPassword = "";
  users.users.root.openssh.authorizedKeys.keyFiles = [ 
    ../../pubkeys/oxy/scarlet.pub
  ];
  security.sudo.wheelNeedsPassword = false;
  services.xserver.displayManager.autoLogin.user = "oxy";

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.11";
}
