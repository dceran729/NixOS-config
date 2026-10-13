{ config, pkgs, ... }:

{
  # ==========================================
  # 1. JELLYFIN (Uruchamiany natywnie dla QuickSync)
  # ==========================================
  services.jellyfin.enable = true;

  # Dodajemy Jellyfina do grupy media i grup renderowania wideo
  users.users.jellyfin.extraGroups = [ "media" "render" "video" ];

  # ==========================================
  # 2. PODMAN (Silnik Kontenerów)
  # ==========================================
  virtualisation.containers.enable = true;
  virtualisation.oci-containers.backend = "podman";

  # ==========================================
  # 3. STACK APLIKACJI OCI
  # ==========================================
  virtualisation.oci-containers.containers = {

    # Klient Torrent
    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      environment = { PUID = "1000"; PGID = "999"; TZ = "Europe/Warsaw"; WEBUI_PORT = "8080"; };
      volumes = [ "/var/lib/containers/qbittorrent:/config" "/data:/data" ];
      ports = [ "8080:8080" "6881:6881" "6881:6881/udp" ];
    };

    # Menedżer Filmów
    radarr = {
      image = "lscr.io/linuxserver/radarr:latest";
      environment = { PUID = "1000"; PGID = "999"; TZ = "Europe/Warsaw"; };
      volumes = [ "/var/lib/containers/radarr:/config" "/data:/data" ];
      ports = [ "7878:7878" ];
    };

    # Menedżer Seriali
    sonarr = {
      image = "lscr.io/linuxserver/sonarr:latest";
      environment = { PUID = "1000"; PGID = "999"; TZ = "Europe/Warsaw"; };
      volumes = [ "/var/lib/containers/sonarr:/config" "/data:/data" ];
      ports = [ "8989:8989" ];
    };

    # Menedżer Indeksatorów
    prowlarr = {
      image = "lscr.io/linuxserver/prowlarr:latest";
      environment = { PUID = "1000"; PGID = "999"; TZ = "Europe/Warsaw"; };
      volumes = [ "/var/lib/containers/prowlarr:/config" ];
      ports = [ "9696:9696" ];
    };

    # Omijanie Cloudflare dla Prowlarra
    flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      environment = { LOG_LEVEL = "info"; TZ = "Europe/Warsaw"; };
      ports = [ "8191:8191" ];
    };

    # Platforma zgłaszania żądań (Requesty)
    jellyseerr = {
      image = "fallenbagel/jellyseerr:latest";
      environment = { LOG_LEVEL = "info"; TZ = "Europe/Warsaw"; };
      volumes = [ "/var/lib/containers/jellyseerr:/app/config" ];
      ports = [ "5055:5055" ];
    };

    # Dashboard / Wizytówka
    homepage = {
      image = "ghcr.io/gethomepage/homepage:latest";
      volumes = [
        "/var/lib/containers/homepage:/app/config"
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro" # Dostęp do statusu kontenerów
      ];
      ports = [ "3001:3000" ];
    };

    # Monitorowanie usług
    uptime-kuma = {
      image = "louislam/uptime-kuma:1";
      volumes = [
        "/var/lib/containers/uptimekuma:/app/data"
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
      ports = [ "3002:3001" ];
    };

    # Przeglądarka logów kontenerów
    dozzle = {
      image = "amir20/dozzle:latest";
      volumes = [ "/var/run/podman/podman.sock:/var/run/docker.sock:ro" ];
      ports = [ "8088:8080" ];
    };
  };
}
