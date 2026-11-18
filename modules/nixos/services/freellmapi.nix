{ config, ... }:

{
  # 1. Sekrety pobierane z secrets/secrets.yaml
  # WAŻNE: Zostaw odkomentowane TYLKO te klucze, które faktycznie wpisałeś
  # do secrets/secrets.yaml — inaczej przebudowa zgłosi brak klucza.
  sops.secrets.freellmapi_encryption_key = {};
  sops.secrets.freellmapi_admin_password = {};

  # sops.secrets.google_api_key = {};
  # sops.secrets.groq_api_key = {};
  # sops.secrets.openrouter_api_key = {};

  # 2. Zmienne środowiskowe kontenera (generowane w RAM)
  sops.templates."freellmapi.env".content = ''
    ENCRYPTION_KEY=${config.sops.placeholder.freellmapi_encryption_key}
    PORT=3012
    HOST_BIND=0.0.0.0
  '';

  # 3. Deklaratywna konfiguracja startowa FreeLLMAPI
  sops.templates."freellmapi.config.json".content = builtins.toJSON {
    owner = "1000";
    group = "1000";
    mode = "0400";
    # Opcjonalne konto admina do panelu WWW (odkomentuj razem z sekretem wyżej):
    admin = {
      email = "d.ceran729@gmail.com";
      password = config.sops.placeholder.freellmapi_admin_password;
    };

    routing = {
      strategy = "balanced";
    };

    # Dopisz/odkomentuj tylko tych dostawców, których klucze masz w secrets.yaml:
    keys = [
      # { platform = "google"; key = config.sops.placeholder.google_api_key; label = "main"; }
      # { platform = "groq"; key = config.sops.placeholder.groq_api_key; label = "main"; }
      # { platform = "openrouter"; key = config.sops.placeholder.openrouter_api_key; label = "main"; }
    ];
  };

  # 4. Kontener OCI (korzysta z virtualisation.oci-containers.backend = "podman" z media.nix)
  virtualisation.oci-containers.containers.freellmapi = {
    image = "ghcr.io/tashfeenahmed/freellmapi:latest";
    autoStart = true;
    extraOptions = [ "--network=host" ];

    volumes = [
      "/var/lib/freellmapi:/app/server/data"
      "${config.sops.templates."freellmapi.config.json".path}:/app/freellmapi.config.json:ro"
    ];

    environment = {
      FREEAPI_CONFIG_PATH = "/app/freellmapi.config.json";
    };

    environmentFiles = [
      config.sops.templates."freellmapi.env".path
    ];
  };

  # 5. Katalog na zaszyfrowaną bazę SQLite
  systemd.tmpfiles.rules = [
    "d /var/lib/freellmapi 0750 1000 1000 -"
  ];

  # 6. Dostęp wyłącznie przez interfejs Tailscale (blokada dla LAN)
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 3012 ];
}
