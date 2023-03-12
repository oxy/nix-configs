{ pkgs, lib, ... } :

{
  users.users.oxy = {
    isNormalUser = true;
    description = "Lucy Satheesan";
    extraGroups = [ "wheel" ] 
      ++ lib.optionals (networking.networkmanager.enable) [ "networkmanager" ]
    ;
    packages = with pkgs; [
      htop
      youtube-dl
    ] ++ lib.optionals (services.xserver.enable) [
      firefox
    ];
    openssh.authorizedKeys.keyFiles = [ 
      ../../pubkeys/oxy/scarlet.pub
    ];
  };
}
