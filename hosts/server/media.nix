{
  config,
  lib,
  pkgs,
  ...
}:

{
  # ---------------------------------------------------------------------
  # WSPÓLNE
  # ---------------------------------------------------------------------

  # Pliki tworzone przez te usługi mają być zapisywalne dla całej grupy
  # "media" (umask 0002) - inaczej np. Radarr nie przeniesie pliku
  # pobranego przez qBittorrenta.
  systemd.services = lib.genAttrs [ "jellyfin" "radarr" "sonarr" "bazarr" "qbittorrent" ] (_: {
    serviceConfig.UMask = lib.mkForce "0002";
  });

  # ---------------------------------------------------------------------
  # JELLYFIN (+ Intel QuickSync)
  # ---------------------------------------------------------------------
  services.jellyfin = {
    enable = true;
    group = "media";
    openFirewall = true;
    # układ katalogów jak w kontenerze linuxserver - nic nie trzeba przenosić
    dataDir = "/var/lib/jellyfin/data";
    configDir = "/var/lib/jellyfin";
    logDir = "/var/lib/jellyfin/log";
  };
  users.users.jellyfin.extraGroups = [
    "render"
    "video"
  ];

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

  services.seerr.enable = true; # port 5055

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
    allowedHosts = "dash.home.arpa,100.95.221.38:3001";
    # TODO: tu trzeba przepisać Twoje services.yaml / settings.yaml / widgets.yaml
    # z /var/lib/containers/homepage na opcje: services = [ ... ]; settings = { ... };
    # (wklej mi te pliki, a je przetłumaczę)
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
