{ lib, config, ... }:
{
  services.openssh = {
    allowSFTP = true; # Don't set this if you need sftp
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
}
