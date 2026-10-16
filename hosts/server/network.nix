{ config, pkgs, ... }:

{
  # 1. TAILSCALE - Dostęp zdalny z każdego miejsca na świecie
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" "podman0" ];
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];

  # 2. ADGUARD HOME - Twój prywatny DNS i bloker reklam
  services.adguardhome = {
    enable = true;
    openFirewall = true; # Automatycznie otwiera porty: 53 (DNS) i 3000 (Panel WWW)
  };
}
