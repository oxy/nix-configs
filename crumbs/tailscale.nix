{ pkgs, ... }:

{
  # make the tailscale command usable to users
  environment.systemPackages = [ pkgs.tailscale ];

  # make tailscale login persist across reboots
  environment.persistence."/nix/persist".directories = [ "/var/lib/tailscale" ];

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
