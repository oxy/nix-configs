{ pkgs, ... }:

{
  # make the tailscale command usable to users
  environment.systemPackages = [ pkgs.tailscale ];

  # enable the tailscale service
  services.tailscale.enable = true;

  # make tailscale login persist across reboots
  environment.persistence."/nix/persist".directories = [ "/var/lib/tailscale" ];
}
