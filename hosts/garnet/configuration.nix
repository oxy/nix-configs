{ ... }:

{
  imports = [
      ../../crumbs/base.nix
      ../../crumbs/networkd.nix
      ../../crumbs/sshd.nix

      ../../users/oxy.nix

      ./hardware-configuration.nix
    ];

  # hostname
  networking.hostName = "garnet";

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # store password in global location
  users.users.oxy.passwordFile = "/nix/persist/secrets/oxy.passwd";
  users.users.root.openssh.authorizedKeys.keyFiles = [ 
    ../../pubkeys/oxy/scarlet.pub
  ];

  # enable samba
  services.samba.enable = true;
  services.samba.openFirewall = true;
  services.samba.shares."movies" = {
    path = "/srv/nas/movies";
    writeable = "yes";
    browseable = "yes";
    public = "no";
  };

  # enable wsdd
  services.samba-wsdd.enable = true;
  networking.firewall.allowedTCPPorts = [ 5357 ];
  networking.firewall.allowedUDPPorts = [ 3702 ];

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.11";
}
