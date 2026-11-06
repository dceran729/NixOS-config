{ config, ... }:

{
  services.tailscale.enable = true;

  networking.firewall = {
    # Port Tailscale w UDP ułatwia bezpośrednie, szybkie połączenia
    allowedUDPPorts = [ config.services.tailscale.port ];
    # Ufaj urządzeniom z sieci Tailscale
    trustedInterfaces = [ "tailscale0" ];
  };
}
