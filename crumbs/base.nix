{ config, lib, pkgs, impermanence, ... }:

{ 
  imports = [
    impermanence.nixosModule
  ];

  time.timeZone = "America/New_York";

  nix.settings.allowed-users = [ "@wheel" ];
  nix.settings.extra-sandbox-paths = [
    "/nix/persist/secrets"
  ];

  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/srv"
      "/var/log"
      "/var/lib"
    ];
    files = [
      "/etc/machine-id"
      { file = "/etc/nix/id_rsa"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];
  };

  fileSystems."/".options = [ "noexec" ];
  fileSystems."/etc/nixos".options = [ "noexec" ];
  fileSystems."/srv".options = [ "noexec" ];
  fileSystems."/var/log".options = [ "noexec" ];

  environment.systemPackages = [
    git  # needed to update flake in /etc/nixos
  ];

  users.mutableUsers = false;
}