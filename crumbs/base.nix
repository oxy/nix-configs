{ config, lib, pkgs, impermanence, ... }:

{ 
  # all of the required services
  config = lib.mkMerge [
    # unconditional things
    import impermanence.nixosModule {}
    
    {

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
        glances
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

      networking.firewall.enable = true;
      networking.nftables.enable = true;
    }

    # conditioned on other config options
    (lib.mkIf config.services.xserver.enable {
      imports = [ ./desktop.nix ];
    })

    (lib.mkIf config.services.jellyfin.enable {
      imports = [ ./jellyfin.nix ];
    })

    (lib.mkIf config.services.openssh.enable {
      imports = [ ./sshd.nix ];
    })

    (lib.mkIf config.services.samba.enable {
      imports = [ ./samba.nix ];
    })

    (lib.mkIf config.services.tailscale.enable {
      imports = [ ./tailscale.nix ];
    })

    (lib.mkIf config.services.transmission.enable {
      imports = [ ./mullvad.nix ./transmission.nix ];
    })

    (lib.mkIf (!config.networking.networkmanager.enable) {
      imports = [ ./networkd.nix ];
    })
  ];

}