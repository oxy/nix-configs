{ ... } : {
  # container for transmission
  containers.transmission = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.111.10";
    localAddress = "192.168.111.11";
    config = { config, pkgs, ... }: {
      services.mullvad-vpn.enable = true;
      services.transmission = {
        enable = true;
      };
      systemd.services."transmission-daemon".after = [ "mullvad-vpn.service" ];

      networking.nftables.enable = true;
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 ]; # TODO: use correct port
      };

      system.stateVersion = "23.05";
    };
  };
}