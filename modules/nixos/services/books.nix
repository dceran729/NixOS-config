{ config, lib, pkgs, ... }:

{
  # ==========================================
  # BAZA DANYCH
  # ==========================================
  services.postgresql = {
    enable = true;
    extensions = ps: with ps; [ pgvector ];
  };

  # ==========================================
  # GŁÓWNE USŁUGI (BookOrbit, Shelfmark, ABS)
  # ==========================================
  services.bookorbit = {
    enable = true;
    createDatabaseLocally = true;
    environmentFile = "/var/lib/secrets/bookorbit.env";
    group = "media";
  };

  services.shelfmark = {
    enable = true;
    environment = {
          SHELFMARK_DOWNLOAD_DIR = "/data/books";
          FLASK_HOST = "0.0.0.0";
    };
  };

  services.audiobookshelf = {
    enable = true;
    host = "0.0.0.0";
    port = 13378;
    group = "media";
  };

  # ==========================================
  # MODYFIKACJA ISTNIEJĄCYCH USŁUG SYSTEMD
  # (Nadanie uprawnień grupie media - umask)
  # ==========================================
  systemd.services.bookorbit.serviceConfig.UMask = lib.mkForce "0002";
  systemd.services.shelfmark.serviceConfig.UMask = lib.mkForce "0002";
  systemd.services.audiobookshelf.serviceConfig.UMask = lib.mkForce "0002";

  # ==========================================
  # TWORZENIE NOWYCH USŁUG SYSTEMD
  # ==========================================

  # 1. Konfiguracja bazy danych BookOrbit
  systemd.services.bookorbit-db-setup = {
    description = "Wymuszenie rozszerzeń bazy danych dla BookOrbit";
    wantedBy = [ "multi-user.target" ];
    before = [ "bookorbit.service" ];
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
    };
    script = ''
      ${pkgs.postgresql}/bin/psql -U postgres -d bookorbit -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";' || true
      ${pkgs.postgresql}/bin/psql -U postgres -d bookorbit -c 'CREATE EXTENSION IF NOT EXISTS "pg_trgm";' || true
      ${pkgs.postgresql}/bin/psql -U postgres -d bookorbit -c 'CREATE EXTENSION IF NOT EXISTS "vector";' || true
    '';
  };

  # 2. Pobieranie wtyczki Shelfmark
  systemd.services.bookorbit-setup-plugin = {
    description = "Pobieranie wtyczki Shelfmark dla BookOrbit";
    wantedBy = [ "multi-user.target" ];
    before = [ "bookorbit.service" ];
    path = [ pkgs.curl pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      DIR="/var/lib/bookorbit/plugins/indexers/shelfmark"
      mkdir -p "$DIR"
      curl -sL "https://raw.githubusercontent.com/aj-may/bookorbit-plugin-shelfmark/main/index.mjs" -o "$DIR/index.mjs"
      chown -R bookorbit:media /var/lib/bookorbit/plugins
      chmod -R 775 /var/lib/bookorbit/plugins
    '';
  };
}
