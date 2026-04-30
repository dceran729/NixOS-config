{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  hardware.bluetooth.enable = true;
}
