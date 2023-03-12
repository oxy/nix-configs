{ pkgs, lib, config, ... } :

{
  users.users.oxy = {
    isNormalUser = true;
    description = "Lucy Satheesan";
    extraGroups = [ "wheel" ] 
      ++ lib.optionals (config.networking.networkmanager.enable) [ "networkmanager" ]
    ;
    packages = with pkgs; [
      vim
      htop
      youtube-dl
    ] ++ lib.optionals (config.services.xserver.enable) [
      firefox
    ];
    openssh.authorizedKeys.keyFiles = [ 
      ../pubkeys/oxy/scarlet.pub
    ];
  };
}
