{ config, lib, pkgs, impermanence, ... }:

{
  imports = [
    impermanence.nixosModule
  ];

  # all of the required services
  config = lib.mkMerge [
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
      networking.networkmanager.enable = lib.mkOverride 999 false;

      # unit to create named network namespaces
      systemd.services."netns@" = {
        description = "Named network namespace %i";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;

          PrivateNetwork = true;
          ExecStart = [
            "${pkgs.iproute}/bin/ip netns add %i"
            "${pkgs.util-linux}/bin/umount /var/run/netns/%i"
            "${pkgs.util-linux}/bin/mount --bind /proc/self/ns/net /var/run/netns/%i"
          ];

          ExecStop = "${pkgs.iproute}/bin/ip netns del %i";
        };
      };
    }

    # if xserver is enabled, pull in gnome and set defaults
    (lib.mkIf config.services.xserver.enable {
      # Enable the GNOME Desktop Environment.
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;

      # Configure keymap in X11
      services.xserver = {
        layout = "us";
        xkbVariant = "";
      };

      # Enable sound with pipewire.
      sound.enable = true;
      hardware.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = false;

        wireplumber.enable = true;
      };
    })

    # if jellyfin is enabled, set up jellyfin + ffmpeg
    (lib.mkIf config.services.jellyfin.enable {
      environment.persistence."/nix/persist".directories = [
        "/var/lib/jellyfin"
        "/var/cache/jellyfin"
      ];

      systemd.services.jellyfin.path = with pkgs; [
        jellyfin-ffmpeg
      ];

      # hardware decoding requires opengl to be enabled
      # (because /run/opengl-drivers/ needs it)
      hardware.opengl.enable = lib.mkDefault true;

      # HACK: this uses the intel-ucode flag, which is janky
      # but all my systems with intel-ucode have intel GPUs so :)
      hardware.opengl.extraPackages = with pkgs; lib.mkIf config.hardware.cpu.intel.updateMicrocode [
        intel-media-driver
        intel-media-sdk
        intel-compute-runtime
        # TODO: package oneapi-vpl
        intel-ocl
      ];
    })

    # if openssh is enabled, set up default sshd config
    (lib.mkIf config.services.openssh.enable {
      services.openssh = {
        allowSFTP = true;
        extraConfig = ''
          AllowTcpForwarding yes
          AllowAgentForwarding no
          AllowStreamLocalForwarding no
          AuthenticationMethods publickey
        '';
      };

      services.openssh.settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
      };

      environment.persistence."/nix/persist".files =
        lib.concatMap (key: [ key.path (key.path + ".pub") ]) config.services.openssh.hostKeys;

      networking.firewall.allowedTCPPorts = [ 22 ];
      networking.firewall.allowedUDPPorts = [  ];
    })

    # if samba is enabled, set up discovery and persist db
    (lib.mkIf config.services.samba.enable {
      services.samba.openFirewall = true;
      environment.persistence."/nix/persist".directories = [ "/var/lib/samba" ];

      # enable wsdd
      services.samba-wsdd.enable = true;
      networking.firewall.allowedTCPPorts = [ 5357 ];
      networking.firewall.allowedUDPPorts = [ 3702 ];
    })

    # if tailscale is enabled, set up persistence and firewall bypass
    (lib.mkIf config.services.tailscale.enable {
      environment.systemPackages = [ pkgs.tailscale ];
      environment.persistence."/nix/persist".directories = [ "/var/lib/tailscale" ];
      networking.firewall.trustedInterfaces = [ "tailscale0" ];
    })

    # if transmission is enabled, set up mullvad and transmission
    (lib.mkIf config.services.transmission.enable {
      # connect to mullvad
      systemd.network.netdevs."10-mullvad" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wgmullvad";
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

      # set up default gateway / route
      systemd.network.networks.wgmullvad = {
        matchConfig.Name = "wgmullvad";
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

      systemd.services."attach-vpn@" = {
        description = "Attach to Mullvad VPN";
        requires = [ "netns@%i.service" ];
        after = [ "netns@%i.service" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;

          ExecStart = [
            # associate NIC with netns
            "${pkgs.iproute}/bin/ip link set wgmullvad netns %i"

            # bring up NIC
            "${pkgs.iproute}/bin/ip netns exec %i ${pkgs.iproute}/bin/ip link set up dev wgmullvad"
            
            # add address / gateway
            "${pkgs.iproute}/bin/ip netns exec %i ${pkgs.iproute}/bin/ip addr add 10.65.153.40 broadcast 10.64.0.255 dev wgmullvad"
            "${pkgs.iproute}/bin/ip netns exec %i ${pkgs.iproute}/bin/ip route add default via 10.64.0.1 dev wgmullvad"
          ];

          ExecStop = "${pkgs.iproute}/bin/ip netns exec %i ${pkgs.iproute}/bin/ip link set down dev wgmullvad";
        };
      };

      # TODO: set up transmission
    })

    # set up networkd if we aren't using networkmanager
    (lib.mkIf (!config.networking.networkmanager.enable) {
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
      } // lib.optionalAttrs (config.networking.wireless.enable) {
        "40-wireless" = {
          enable = true;
          name = "wl*";
          inherit networkConfig;
          dhcpV4Config.RouteMetric = 2048;
        };
      };
    })
  ];

}