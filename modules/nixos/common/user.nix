{ config, pkgs, ... }:

{
  users.users.damian2120 = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
