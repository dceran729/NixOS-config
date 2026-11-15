{ config, pkgs, ... }:

{
  programs.fish.enable=true;

  users.users.damian2120 = {
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
