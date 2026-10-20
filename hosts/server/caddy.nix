{ config, pkgs, ... }:

{
  # Otwieramy porty HTTP (80) i HTTPS (443) w zaporze sieciowej
  networking.firewall.allowedTCPPorts = [
    80
    443
    8443
  ];

  services.caddy = {
    enable = true;

    virtualHosts = {
      # Vaultwarden na bezpiecznym połączeniu HTTPS z wewnętrznym certyfikatem SSL
      "https://100.95.221.38:8443" = {
        extraConfig = ''
          tls internal
          reverse_proxy 127.0.0.1:8222
        '';
      };

      # Tutaj w przyszłości możesz dodawać kolejne usługi, np.:
      # "jellyfin.local" = {
      #   extraConfig = ''
      #     tls internal
      #     reverse_proxy 127.0.0.1:8096
      #   '';
      # };
    };
  };
}
