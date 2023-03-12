{ ... } :

{
  # networking
  networking = {
    hostname = "carmine";
    useDHCP = false;
    useNetworkd = true;
  };

  systemd.network.networks = let
    networkConfig = {
      DHCP = "yes";
    };
  in {
    "40-wired" = {
      enable = "true";
      name = "en*";
      inherit networkConfig;
    };
  };
}