{ pkgs, lib, ... } :

{
  users.users.oxy = {
    extra-groups = [ "networkmanager" ];
    packages = with pkgs; [
      firefox
    ];
  };
}
