{ config, ... } : {
  # transmission container!
  # some configuration required:
  # 
  # 1. requires NAT enabled
  # 2. requires manual setup for mullvad
  # 3. requires bind mount for Downloads
  #
  # for bind mount, use:
  # containers.transmission.bindMounts = {
  #   "/var/lib/transmission/Downloads" = {
  #     hostPath = "/mnt/Downloads";
  #     isReadOnly = false;
  #   };
  # };

  users.users."transmission" = {
    description = "Transmission account for container permission management";
    isSystemUser = true;
    createHome = false;
    uid = config.containers.transmission.config.users.users."transmission".uid;
  };

  # systemd-networkd DNS configuration
  networking.firewall.interfaces."ve-transmission" = {
    allowedUDPPorts = [ 67 ];
  };

  # container for transmission
  containers.transmission = {
    autoStart = true;
    privateNetwork = true;
    extraFlags = [ "--network-veth" ];
    forwardPorts = [
      {
        hostPort = 9091;
        containerPort = 9091;
        protocol = "tcp";
      }
    ];

    config = { config, pkgs, ... }: {
      services.mullvad-vpn.enable = true;
      services.transmission = {
        enable = true;
        openFirewall = true;

        settings = {
          download-dir = "/var/lib/transmission/Downloads";
          rpc-bind-address = "0.0.0.0";
          rpc-whitelist-enabled = false;
        };
      };

      users.users."transmission".uid = 70;
      systemd.services."transmission-daemon".requires = [ "mullvad-daemon.service" ];

      # networking
      networking.nftables.enable = true;
      networking.firewall.enable = true;
      networking.firewall.trustedInterfaces = [ "host0" ];
      networking.useHostResolvConf = false;
      networking.useNetworkd = true;

      # manually configure wireguard
      environment.etc."wireguard/wgvpn.conf" = {
        source = "/nix/secrets/wireguard.conf";
        mode = "0600";
      };

      # add wireguard interface
      environment.systemPackages = with pkgs; [ wireguard-tools ];
      systemd.services."wg-quick@wgvpn".enable = true;

      system.stateVersion = "23.05";
    };
  };
}