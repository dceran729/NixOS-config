{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  networking.firewall.trustedInterfaces = [ "podman0" ];

  # ADGUARD HOME - prywatny DNS i bloker reklam
  services.adguardhome = {
    enable = true;
    openFirewall = true;
  };
}
