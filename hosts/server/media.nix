{ config, lib, pkgs, ... }:

let
  # ---- Ustawienia panelu Homepage ------------------------------------
  hostIp = "100.95.221.38";
  domain = "home.arpa";
  # false = linki prowadzą na http://IP:port (działa od razu).
  # true  = linki prowadzą na https://nazwa.home.arpa (po konfiguracji
  #         AdGuard + Tailscale DNS i certyfikatu Caddy).
  useDomains = false;

  # Nazwy grup (używane i w układzie, i na liście usług - muszą się zgadzać)
  gMedia = "Multimedia";
  gAuto  = "Automatyzacja";
  gDl    = "Pobieranie";
  gSys   = "System";

  # Jedna kafelka: link + wskaźnik działania (zielona kropka) bez kluczy API
  svc = { name, sub, port, icon, desc }: {
    ${name} = {
      inherit icon;
      description = desc;
      href =
        if useDomains
        then "https://${sub}.${domain}"
        else "http://${hostIp}:${toString port}";
      siteMonitor = "http://127.0.0.1:${toString port}";
    };
  };
in
{
  # ---------------------------------------------------------------------
  # WSPÓLNE
  # ---------------------------------------------------------------------

  # Pliki tworzone przez te usługi mają być zapisywalne dla całej grupy
  # "media" (umask 0002) - inaczej np. Radarr nie przeniesie pliku
  # pobranego przez qBittorrenta.
  systemd.services = lib.genAttrs
    [ "jellyfin" "radarr" "sonarr" "bazarr" "qbittorrent" ]
    (_: { serviceConfig.UMask = lib.mkForce "0002"; });

  # ---------------------------------------------------------------------
  # JELLYFIN (+ Intel QuickSync)
  # ---------------------------------------------------------------------
  services.jellyfin = {
    enable = true;
    group = "media";
    openFirewall = true; # 8096/8920 + wykrywanie w LAN (1900/udp, 7359/udp) dla TV
    # Układ katalogów taki jak w kontenerze linuxserver (dane skopiowane
    # z /var/lib/containers/jellyfin), dzięki czemu nic nie trzeba przenosić.
    configDir = "/var/lib/jellyfin";
    dataDir = "/var/lib/jellyfin/data";
    logDir = "/var/lib/jellyfin/log";
  };
  users.users.jellyfin.extraGroups = [ "render" "video" ];

  # ---------------------------------------------------------------------
  # ARR STACK
  # ---------------------------------------------------------------------
  services.radarr = {
    enable = true; # port 7878
    group = "media";
  };

  services.sonarr = {
    enable = true; # port 8989
    group = "media";
  };

  services.prowlarr.enable = true; # port 9696

  services.bazarr = {
    enable = true; # port 6767
    group = "media";
  };

  services.flaresolverr.enable = true; # port 8191

  services.jellyseerr.enable = true; # port 5055

  # ---------------------------------------------------------------------
  # TORRENTY
  # ---------------------------------------------------------------------
  services.qbittorrent = {
    enable = true;
    group = "media";
    webuiPort = 8080;
    torrentingPort = 6881;
  };
  networking.firewall.allowedTCPPorts = [ 6881 ];
  networking.firewall.allowedUDPPorts = [ 6881 ];

  # Moduł qui z nixpkgs (port domyślnie 7476). Połączenie z qBittorrentem
  # ustawiasz w jego panelu: http://127.0.0.1:8080
  services.qui = {
    enable = true;
    # Wymagane. Plik z losowym sekretem sesji (sam ciąg znaków, bez nazwy
    # zmiennej), poza /nix/store. Tworzysz go ręcznie:
    #   openssl rand -hex 32 | sudo tee /var/lib/secrets/qui-session
    secretFile = "/var/lib/secrets/qui-session";
  };

  # ---------------------------------------------------------------------
  # PANEL, MONITORING, HASŁA, SYNCHRONIZACJA, ZDALNY PULPIT
  # ---------------------------------------------------------------------
  services.homepage-dashboard = {
    enable = true;
    listenPort = 3001;
    allowedHosts = "dash.${domain},${hostIp}:3001,localhost:3001,127.0.0.1:3001";

    settings = {
      title = "Centrum Dowodzenia";
      language = "pl";
      theme = "dark";
      color = "neutral";
      headerStyle = "clean";
      statusStyle = "dot";
      hideVersion = true;
      disableUpdateCheck = true;
      useEqualHeights = true;
      target = "_blank";
      layout = {
        ${gMedia} = { style = "row"; columns = 4; };
        ${gAuto}  = { style = "row"; columns = 4; };
        ${gDl}    = { style = "row"; columns = 4; };
        ${gSys}   = { style = "row"; columns = 4; };
      };
    };

    # Pasek informacji u góry
    widgets = [
      { datetime = {
          text_size = "xl";
          locale = "pl";
          format = { timeStyle = "short"; hourCycle = "h23"; };
        }; }
      { resources = { cpu = true; memory = true; disk = "/"; label = "System"; }; }
      { resources = { disk = "/data"; label = "Dane"; }; }
      { search = { provider = "google"; target = "_blank"; }; }
    ];

    services = [
      { ${gMedia} = [
          (svc { name = "Jellyfin"; sub = "jellyfin";   port = 8096; icon = "jellyfin.svg";   desc = "Filmy i seriale"; })
          (svc { name = "Seerr";    sub = "jellyseerr"; port = 5055; icon = "jellyseerr.svg"; desc = "Prośby o nowe tytuły"; })
        ]; }
      { ${gAuto} = [
          (svc { name = "Radarr";   sub = "radarr";   port = 7878; icon = "radarr.svg";   desc = "Filmy"; })
          (svc { name = "Sonarr";   sub = "sonarr";   port = 8989; icon = "sonarr.svg";   desc = "Seriale"; })
          (svc { name = "Prowlarr"; sub = "prowlarr"; port = 9696; icon = "prowlarr.svg"; desc = "Indeksery"; })
          (svc { name = "Bazarr";   sub = "bazarr";   port = 6767; icon = "bazarr.svg";   desc = "Napisy"; })
        ]; }
      { ${gDl} = [
          (svc { name = "qBittorrent"; sub = "qbit";  port = 8080; icon = "qbittorrent.svg"; desc = "Torrenty"; })
          (svc { name = "qui";         sub = "qui";   port = 7476; icon = "autobrr.png";     desc = "Panel qBittorrenta"; })
          (svc { name = "Syncthing";   sub = "sync";  port = 8384; icon = "syncthing.svg";   desc = "Synchronizacja"; })
        ]; }
      { ${gSys} = [
          (svc { name = "Vaultwarden"; sub = "vault";   port = 8222; icon = "vaultwarden.svg";  desc = "Hasła"; })
          (svc { name = "Uptime Kuma"; sub = "kuma";    port = 3002; icon = "uptime-kuma.svg";  desc = "Monitoring"; })
          (svc { name = "AdGuard";     sub = "adguard"; port = 3000; icon = "adguard-home.svg"; desc = "DNS i reklamy"; })
        ]; }
    ];

    customCSS = ''
      :root {
        --hp-bg: #0a0a0b;
        --hp-surface: rgba(255, 255, 255, 0.035);
        --hp-surface-hover: rgba(255, 255, 255, 0.065);
        --hp-line: rgba(255, 255, 255, 0.08);
        --hp-line-hover: rgba(255, 255, 255, 0.2);
        --hp-text: #ececee;
        --hp-muted: #85858f;
        --hp-accent: #8ab4ff;
      }

      html, body, #__next, #page_wrapper, #inner_wrapper {
        background: var(--hp-bg) !important;
        color: var(--hp-text);
        font-family: ui-sans-serif, system-ui, "Inter", "Segoe UI", sans-serif;
        -webkit-font-smoothing: antialiased;
      }

      ::selection { background: rgba(138, 180, 255, 0.28); }

      #page_container {
        max-width: 1080px;
        margin-left: auto;
        margin-right: auto;
      }

      /* pasek informacji: spokojny, bez ramek */
      #information-widgets { font-variant-numeric: tabular-nums; opacity: 0.92; }

      /* nagłówki grup: małe, rozstrzelone, przygaszone */
      .service-group-name, .bookmark-group-name {
        font-size: 0.68rem !important;
        font-weight: 600 !important;
        letter-spacing: 0.18em;
        text-transform: uppercase;
        color: var(--hp-muted) !important;
      }

      /* kafelki: płaskie, cienka ramka, bez cieni */
      .service-card, .service .service-card {
        background: var(--hp-surface) !important;
        border: 1px solid var(--hp-line) !important;
        border-radius: 12px !important;
        box-shadow: none !important;
        backdrop-filter: none !important;
        transition: background 0.18s ease, border-color 0.18s ease, transform 0.18s ease;
      }
      .service-card:hover {
        background: var(--hp-surface-hover) !important;
        border-color: var(--hp-line-hover) !important;
        transform: translateY(-1px);
      }

      .service-name { font-weight: 500; color: var(--hp-text) !important; }
      .service-description {
        font-size: 0.74rem !important;
        color: var(--hp-muted) !important;
      }

      /* delikatny pasek przewijania */
      * { scrollbar-width: thin; scrollbar-color: rgba(255,255,255,0.15) transparent; }
    '';
    # customJS celowo nie jest używane: ten wygląd nie potrzebuje skryptów.
  };

  services.uptime-kuma = {
    enable = true;
    settings = {
      PORT = "3002";
      HOST = "127.0.0.1";
    };
  };

  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    config = {
      DOMAIN = "https://vault.home.arpa";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      SIGNUPS_ALLOWED = false; # włącz tylko na chwilę, gdy zakładasz nowe konto
    };
  };

  services.syncthing = {
    enable = true;
    user = "damian2120";
    group = "media";
    dataDir = "/data/syncthing";
    configDir = "/var/lib/syncthing";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = true; # 22000 tcp/udp, 21027 udp
    # Kontener miał nowszą wersję Syncthinga niż nixpkgs; bez tej flagi
    # program odmawia startu na skopiowanym pliku konfiguracji.
    extraFlags = [ "--allow-newer-config" ];
  };

  services.rustdesk-server = {
    enable = true;
    openFirewall = true;
    signal.relayHosts = [ "100.95.221.38" ];
  };

  # ---------------------------------------------------------------------
  # KONTENERY, KTÓRE ZOSTAJĄ (brak modułu NixOS)
  # ---------------------------------------------------------------------
  virtualisation.containers.enable = true;
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers = {
    oracle-db = {
      image = "container-registry.oracle.com/database/free:latest";
      # Hasło w pliku poza /nix/store. Plik: /var/lib/secrets/oracle.env
      # z jedną linijką: ORACLE_PWD=twoje_haslo
      environmentFiles = [ "/var/lib/secrets/oracle.env" ];
      volumes = [ "oracle_data:/opt/oracle/oradata" ];
      ports = [ "1521:1521" ];
      extraOptions = [ "--shm-size=1g" ];
    };
  };
}
