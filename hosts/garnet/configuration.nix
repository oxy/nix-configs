{ ... }:

{
  imports = [
      ../../crumbs/base.nix
      ../../crumbs/networkd.nix
      ../../crumbs/sshd.nix
      ../../crumbs/samba.nix
      
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

  services.samba.shares."movies" = {
    path = "/srv/nas/movies";
    writeable = "yes";
    browseable = "yes";
    public = "no";
  };

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.11";
}
