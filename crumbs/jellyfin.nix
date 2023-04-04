{ lib, config, pkgs, ... } :

{
  services.jellyfin.enable = true;

  environment.persistence."/nix/persist".directories = [
    "/var/lib/jellyfin"
    "/var/cache/jellyfin"
  ];

  systemd.services.jellyfin.path = with pkgs; [
    jellyfin-ffmpeg
  ];
}
