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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/srv"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
      { file = "/etc/nix/id_rsa"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];
  };

  fileSystems."/".options = [ "noexec" ];
  fileSystems."/srv".options = [ "noexec" ];
  fileSystems."/var/log".options = [ "noexec" ];

  environment.systemPackages = with pkgs; [
    git  # needed to update flake in /etc/nixos
  ];

  # set locale to en_US
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  users.mutableUsers = false;
}