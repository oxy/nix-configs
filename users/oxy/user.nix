{ pkgs, lib, ... } :

{
  users.users.oxy = {
    isNormalUser = true;
    description = "Lucy Satheesan";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = [ 
      ../../pubkeys/oxy/scarlet.pub
    ];
  };
}