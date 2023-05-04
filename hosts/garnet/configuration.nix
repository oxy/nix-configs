{ config, ... }:

{
  imports = [
      ../../crumbs/base.nix
      ../../containers/transmission.nix
      ../../users/oxy.nix

      ./hardware-configuration.nix
    ];

  # hostname
  networking.hostName = "garnet";

  # services
  services.openssh.enable = true;
  services.jellyfin.enable = true;
  services.tailscale.enable = true;

  # create a movies group for jellyfin/transmission/...
  users.groups.movies.members = [
    "oxy"
    "jellyfin"
    "transmission"
  ];

  # wireless networking
  networking.wireless.enable = true;

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # store password in global location
  # XXX: currently broken on nixos-unstable
  users.allowNoPasswordLogin = true;
  users.users.oxy.passwordFile = "/nix/persist/secrets/oxy.passwd";
  users.users.root.openssh.authorizedKeys.keyFiles = [ 
    ../../pubkeys/oxy/scarlet.pub
  ];

  # set up samba
  services.samba.enable = true;
  services.samba.shares."movies" = {
    path = "/srv/nas/movies";
    writeable = "yes";
    browseable = "yes";
    public = "no";
  };

  # set up transmission
  containers.transmission.bindMounts = {
    "/var/lib/transmission/Downloads" = {
      hostPath = "/srv/nas/movies";
      isReadOnly = false;
    };
  };

  containers.transmission.config.services.transmission.settings.peer-port = 55828;

  # XXX: transmission has a fixed uid/gid right now, steal it for jellyfin/movies
  users.users."jellyfin".uid = config.containers.transmission.config.users.users."transmission".uid;
  users.groups."movies".gid = config.containers.transmission.config.users.groups."transmission".gid;

  # disable sleep on lid close when powered
  services.logind.lidSwitchExternalPower = "ignore";

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "22.11";
}
