{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Domena wewnętrzna zarezerwowana na sieci prywatne (RFC 8375).
  # NIE używaj ".local" - koliduje z mDNS.
  domain = "home.arpa";

  # nazwa -> port na 127.0.0.1
  apps = {
    jellyfin = {
      port = 8096;
    };
    jellyseerr = {
      port = 5055;
    };
    radarr = {
      port = 7878;
    };
    sonarr = {
      port = 8989;
    };
    prowlarr = {
      port = 9696;
    };
    bazarr = {
      port = 6767;
    };
    qbit = {
      port = 8080;
    };
    qui = {
      port = 7476;
    };
    vault = {
      port = 8222;
    };
    dash = {
      port = 3001;
    };
    kuma = {
      port = 3002;
    };
    adguard = {
      port = 3000;
    };
    # Syncthing odrzuca nieznany nagłówek Host ("Host check error"),
    # więc podmieniamy go na adres upstreamu.
    sync = {
      port = 8384;
      keepUpstreamHost = true;
    };
  };

  mkVhost =
    name: app:
    lib.nameValuePair "${name}.${domain}" {
      extraConfig = ''
        tls internal
        reverse_proxy 127.0.0.1:${toString app.port} {
          ${lib.optionalString (app.keepUpstreamHost or false) "header_up Host {upstream_hostport}"}
        }
      '';
    };
in
{
  # 80 -> automatyczne przekierowanie na HTTPS, 443 -> właściwy ruch
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.caddy = {
    enable = true;
    virtualHosts = lib.mapAttrs' mkVhost apps;
  };

  # Certyfikat główny Caddy (do zaimportowania na urządzeniach):
  #   /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt
}
