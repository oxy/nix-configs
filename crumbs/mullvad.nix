{ lib, ... } :

{
  systemd.network.netdevs."10-wg0" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "wg0";
    };
    wireguardConfig = {
      ListenPort = 51820;
      PrivateKeyFile = "/nix/secrets/mullvad.key";
      RouteTable = "main";
      RouteMetric = 8192;
    };
    wireguardPeers = [{
      wireguardPeerConfig = {
        PublicKey = "6CwMg2aoKNSFFcIsW3R3SY5T6fBYwoRFifl8ZVlw+Vg=";
        AllowedIPs = [ "0.0.0.0/0" "::0/0" ];
        Endpoint = "66.63.167.194:51820";
      };
    }];
  };

  systemd.network.networks.wg0 = {
    matchConfig.Name = "wg0";
    address = lib.mkDefault [
      "10.65.153.40/32"
      "fc00:bbbb:bbbb:bb01::2:9927/128"
    ];
    DHCP = "no";
    dns = [ "100.64.0.7" ];
    gateway = [ "10.64.0.1" ];
    networkConfig = {
      IPv6AcceptRA = false;
    };
  };
}
