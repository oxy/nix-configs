{ ... }:
{
  services.openssh = {
    passwordAuthentication = false;
    allowSFTP = false; # Don't set this if you need sftp
    challengeResponseAuthentication = false;
    extraConfig = ''
      AllowTcpForwarding yes
      X11Forwarding no
      AllowAgentForwarding no
      AllowStreamLocalForwarding no
      AuthenticationMethods publickey
    '';
  };

  services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [  ];
}
