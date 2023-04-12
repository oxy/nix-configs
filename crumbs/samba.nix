{ ... }:

{
  # enable samba
  services.samba.openFirewall = true;

  environment.persistence."/nix/persist".directories = [ "/var/lib/samba" ];

  # enable wsdd
  services.samba-wsdd.enable = true;
  networking.firewall.allowedTCPPorts = [ 5357 ];
  networking.firewall.allowedUDPPorts = [ 3702 ];
}
