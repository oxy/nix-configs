{ ... }:

{
  imports = [
      ../../crumbs/base.nix
      ../../containers/transmission.nix
      ../../users/oxy.nix

      ./hardware-configuration.nix
    ];

  # hostname
  networking.hostName = "carmine";

  # services
  services.openssh.enable = true;
  services.xserver.enable = true;

  containers.transmission.bindMounts = {
    "/var/lib/transmission/Downloads" = {
      hostPath = "/nix/persist/transmission/downloads";
      isReadOnly = false;
    };
  };

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
