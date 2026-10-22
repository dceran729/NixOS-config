{ config, pkgs, ... }:

{
  # Usunięto systemowego Jellyfina (services.jellyfin = { ... })
  # oraz systemowe grupy (users.users.jellyfin...)

  virtualisation.containers.enable = true;
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers = {
    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      environment = {
        PUID = "1000";
        PGID = "999";
        TZ = "Europe/Warsaw";
        WEBUI_PORT = "8080";
      };
      volumes = [
        "/var/lib/containers/qbittorrent:/config"
        "/data:/data"
      ];
      ports = [
        "8080:8080"
        "6881:6881"
        "6881:6881/udp"
      ];
    };

    radarr = {
      image = "lscr.io/linuxserver/radarr:latest";
      environment = {
        PUID = "1000";
        PGID = "999";
        TZ = "Europe/Warsaw";
      };
      volumes = [
        "/var/lib/containers/radarr:/config"
        "/data:/data"
      ];
      ports = [ "7878:7878" ];
    };

    sonarr = {
      image = "lscr.io/linuxserver/sonarr:latest";
      environment = {
        PUID = "1000";
        PGID = "999";
        TZ = "Europe/Warsaw";
      };
      volumes = [
        "/var/lib/containers/sonarr:/config"
        "/data:/data"
      ];
      ports = [ "8989:8989" ];
    };

    prowlarr = {
      image = "lscr.io/linuxserver/prowlarr:latest";
      environment = {
        PUID = "1000";
        PGID = "999";
        TZ = "Europe/Warsaw";
      };
      volumes = [ "/var/lib/containers/prowlarr:/config" ];
      ports = [ "9696:9696" ];
    };

    flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      environment = {
        LOG_LEVEL = "info";
        TZ = "Europe/Warsaw";
      };
      ports = [ "8191:8191" ];
    };

    jellyseerr = {
      image = "fallenbagel/jellyseerr:develop";
      environment = {
        LOG_LEVEL = "info";
        TZ = "Europe/Warsaw";
      };
      volumes = [ "/var/lib/containers/jellyseerr:/app/config" ];
      ports = [ "5055:5055" ];
    };

    bazarr = {
      image = "lscr.io/linuxserver/bazarr:latest";
      autoStart = true;
      ports = [ "6767:6767" ];
      volumes = [
        "/var/lib/containers/bazarr:/config"
        "/data/media:/data/media"
      ];
      environment = {
        PUID = "1000";
        PGID = "999";
        TZ = "Europe/Warsaw";
      };
    };

    homepage = {
      image = "ghcr.io/gethomepage/homepage:latest";
      volumes = [
        "/var/lib/containers/homepage:/app/config"
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
      ports = [ "3001:3000" ];
      environment = {
        HOMEPAGE_ALLOWED_HOSTS = "100.95.221.38:3001,192.168.1.21:3001";
      };
    };

    uptime-kuma = {
      image = "louislam/uptime-kuma:2";
      volumes = [
        "/var/lib/containers/uptimekuma:/app/data"
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
      ports = [ "3002:3001" ];
    };

    vaultwarden = {
      image = "vaultwarden/server:latest";
      environment = {
        TZ = "Europe/Warsaw";
        SIGNUPS_ALLOWED = "true";
      };
      volumes = [ "/var/lib/containers/vaultwarden:/data" ];
      ports = [ "8222:80" ];
    };

    syncthing = {
      image = "lscr.io/linuxserver/syncthing:latest";
      environment = {
        PUID = "1000";
        PGID = "999";
        TZ = "Europe/Warsaw";
      };
      volumes = [
        "/var/lib/containers/syncthing:/config"
        "/data/syncthing:/data1"
      ];
      ports = [
        "8384:8384"
        "22000:22000"
        "22000:22000/udp"
        "21027:21027/udp"
      ];
    };

    rustdesk-hbbs = {
      image = "rustdesk/rustdesk-server:latest";
      cmd = [
        "hbbs"
        "-r"
        "100.95.221.38"
      ];
      volumes = [ "/var/lib/containers/rustdesk:/root" ];
      ports = [
        "21115:21115"
        "21116:21116"
        "21116:21116/udp"
        "21118:21118"
      ];
    };

    rustdesk-hbbr = {
      image = "rustdesk/rustdesk-server:latest";
      cmd = [ "hbbr" ];
      volumes = [ "/var/lib/containers/rustdesk:/root" ];
      ports = [
        "21117:21117"
        "21119:21119"
      ];
    };

    dozzle = {
      image = "amir20/dozzle:latest";
      volumes = [ "/var/run/podman/podman.sock:/var/run/docker.sock:ro" ];
      ports = [ "8088:8080" ];
    };

    # === NOWY KONTENER: Jellyfin ===
    jellyfin = {
      image = "lscr.io/linuxserver/jellyfin:latest";
      environment = {
        PUID = "1000";
        PGID = "999";
        TZ = "Europe/Warsaw";
      };
      volumes = [
        "/var/lib/containers/jellyfin:/config"
        "/data:/data"
      ];
      ports = [
        "8096:8096"
        "8920:8920"
        "7359:7359/udp"
        "1900:1900/udp"
      ];
      extraOptions = [
        "--device=/dev/dri:/dev/dri"
      ];
    };

    # === NOWY KONTENER: qui ===
    qui = {
      image = "ghcr.io/autobrr/qui:latest";
      environment = {
        TZ = "Europe/Warsaw";
      };
      volumes = [
        "/var/lib/containers/qui:/config"
        "/data:/data"
      ];
      ports = [ "7476:7476" ];
    };

    oracle-db = {
      image = "container-registry.oracle.com/database/free:latest";
      environment = {
        ORACLE_PASSWORD = "qwe321";
      };
      volumes = [
        "/var/lib/containers/oracle:/opt/oracle/oradata"
      ];
      ports = [ "1521:1521" ];
      # DODANA LINIJKA - Zwiększenie SHM do 1 GB:
      extraOptions = [ "--shm-size=1g" ];
    };
  };
}
