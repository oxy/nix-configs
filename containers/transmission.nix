{ config, lib, ... } : {
  # transmission container!
  # some configuration required:
  # 
  # 1. assumes networkd is used (on my machines, yes)
  # 2. assumes wireguard vpn (config stored in /nix/secrets/wireguard/wgvpn.conf)
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
    group = "transmission";
  };

  users.groups."transmission" = {
    gid = config.containers.transmission.config.users.groups."transmission".gid;
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

    bindMounts = {
      "/etc/wireguard" = {
        hostPath = lib.mkDefault "/nix/secrets/wireguard";
        isReadOnly = false;
      };
    };

    config = { config, pkgs, ... }: {
      services.transmission = {
        enable = true;
        openFirewall = true;

        settings = {
          download-dir = "/var/lib/transmission/Downloads";
          rpc-bind-address = "0.0.0.0";
          rpc-whitelist-enabled = false;
        };
      };

      systemd.services."transmission-daemon".requires = [ "wg-vpn.service" ];

      # networking
      networking.nftables.enable = true;
      networking.firewall.enable = true;
      networking.firewall.trustedInterfaces = [ "host0" ];
      networking.useHostResolvConf = false;
      networking.useNetworkd = true;

      # add wireguard interface
      environment.systemPackages = with pkgs; [ wireguard-tools ];
      systemd.services."wg-vpn" = {
        enable = true;
        description = "Wireguard VPN";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        path = with pkgs; [ wireguard-tools ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.wireguard-tools}/bin/wg-quick up wgvpn";
          ExecStop = "${pkgs.wireguard-tools}/bin/wg-quick down wgvpn";
        };
      };

      system.stateVersion = "23.05";
    };
  };
}