{ pkgs, lib, ... } :

{
  users.users.oxy = {
    extraGroups = [ "networkmanager" ];
    packages = with pkgs; [
      firefox
    ];
  };
}
