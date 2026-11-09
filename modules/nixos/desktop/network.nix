{ config, pkgs, ... }:

{
  networking.wireless.iwd.enable = true;
  services.resolved.enable = true;

  # NetworkManager (używany w Waybarze) ma używać iwd jako silnika do WiFi:
  networking.networkmanager.wifi.backend = "iwd";
}
