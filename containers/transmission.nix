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
      }
    ];

    config = { config, pkgs, ... }: {
      services.mullvad-vpn.enable = true;
      services.transmission = {
        enable = true;
        openRPCPort = true;
        openFirewall = true;

        settings = {
          download-dir = "/var/lib/transmission/Downloads"; # TODO: change
        };
      };
      systemd.services."transmission-daemon".after = [ "mullvad-vpn.service" ];

      # networking
      networking.nftables.enable = true;
      networking.firewall.enable = true;

      # manually configure nameserver
      environment.etc."resolv.conf".text = "nameserver 8.8.8.8";

      system.stateVersion = "23.05";
    };
  };
}