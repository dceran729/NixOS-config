{ config, pkgs, ... }:

{
  networking.hostName = "DCNIX";
  networking.networkmanager.enable = true;
}
