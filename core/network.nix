{ config, pkgs, ... }:

{
  networking.hostName = "DCNIX";
  #networking.networkmanager.enable = true;
  # To musi trafić do konfiguracji systemowej (NixOS), NIE do Home Managera
  networking.wireless.iwd.enable = true;

  # Jeśli używasz NetworkManagera (a używasz go w Waybarze),
  # musisz mu powiedzieć, żeby używał iwd jako silnika do WiFi:
  networking.networkmanager.wifi.backend = "iwd";
}
