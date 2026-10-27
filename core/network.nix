{ config, pkgs, ... }:

{
  networking.hostName = "DCNIX";
  networking.networkmanager.enable = true;
  networking.wireless.iwd.enable = false;
    services.resolved.enable = true;

  # Jeśli używasz NetworkManagera (a używasz go w Waybarze),
  # musisz mu powiedzieć, żeby używał iwd jako silnika do WiFi:
  # ==========================================
  # DODANE: Usługa Tailscale
  # ==========================================
  services.tailscale.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 53317 ];
    # Dodajemy port Tailscale do UDP, co ułatwi bezpośrednie, szybkie połączenia
    allowedUDPPorts = [ 53317 config.services.tailscale.port ];
    # Mówimy systemowi: "Ufaj urządzeniom z mojej sieci Tailscale"
    trustedInterfaces = [ "tailscale0" ];
  };
}
