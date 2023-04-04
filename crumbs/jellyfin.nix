{ lib, config, ... } :

{
  services.jellyfin.enable = true;

  environment.persistence."/nix/persist".directories = [
    "/var/lib/jellyfin"
    "/var/cache/jellyfin"
  ];

}
