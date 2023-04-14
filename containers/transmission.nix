{ ... } : {
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
    name = "Transmission";
    description = "Transmission account for container permission management";
    isSystemUser = true;
    createHome = false;
    uid = 100;
  };

  # enable nat for the container
  networking.nat.internalInterfaces = [ "ve-transmission" ];

  # container for transmission
  containers.transmission = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.111.10";
    localAddress = "192.168.111.11";
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
          rpc-bind-address = "192.168.111.11";
          rpc-whitelist-enabled = false;
        };
      };

      users.users."transmission".uid = 100;
      systemd.services."transmission-daemon".requires = [ "mullvad-daemon.service" ];

      # networking
      networking.nftables.enable = true;
      networking.firewall.enable = true;
      networking.firewall.trustedInterfaces = [ "eth0" ];

      # manually configure nameserver
      environment.etc."resolv.conf".text = "nameserver 8.8.8.8";

      system.stateVersion = "23.05";
    };
  };
}