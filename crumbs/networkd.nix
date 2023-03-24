{ lib, config, ... } :

{
  # networking
  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  systemd.network.networks = let
  networkConfig = {
    DHCP = "yes";
  }; in {
    "40-wired" = {
      enable = true;
      name = "en*";
      inherit networkConfig;
      dhcpV4Config.RouteMetric = 1024;
    };
  } // lib.optionals (config.networking.wireless.enable) {
    "40-wireless" = {
      enable = true;
      name = "wl*";
      inherit networkConfig;
      dhcpV4Config.RouteMetric = 2048;
    };
  };
}
