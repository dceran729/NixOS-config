{ config, lib, pkgs, ... }:

{
  # 1. POSTGRESQL + ROZSZERZENIA DLA BOOKORBIT (pgvector)
  services.postgresql = {
    enable = true;
    extensions = ps: with ps; [ pgvector ];
  };

  # Wymuszamy utworzenie specyficznych rozszerzeń wewnątrz bazy 'bookorbit'
  systemd.services.bookorbit-db-setup = {
    description = "Wymuszenie rozszerzeń bazy danych dla BookOrbit";
    wantedBy = [ "multi-user.target" ];
    before = [ "bookorbit.service" ];
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    script = ''
      ${pkgs.postgresql}/bin/psql -U postgres -d bookorbit -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";' || true
      ${pkgs.postgresql}/bin/psql -U postgres -d bookorbit -c 'CREATE EXTENSION IF NOT EXISTS "pg_trgm";' || true
      ${pkgs.postgresql}/bin/psql -U postgres -d bookorbit -c 'CREATE EXTENSION IF NOT EXISTS "vector";' || true
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
    };
  };

  # 2. BOOKORBIT
  services.bookorbit = {
    enable = true;
    createDatabaseLocally = true; # Sam założy użytkownika i bazę
    environmentFile = "/var/lib/secrets/bookorbit.env";
    group = "media";
  };

  # 3. WTYCZKA SHELFMARK (Pobierana automatycznie przed startem BookOrbita)
  systemd.services.bookorbit-setup-plugin = {
    description = "Pobieranie wtyczki Shelfmark dla BookOrbit";
    wantedBy = [ "multi-user.target" ];
    before = [ "bookorbit.service" ];
    path = [ pkgs.curl pkgs.coreutils ];
    script = ''
      DIR="/var/lib/bookorbit/plugins/indexers/shelfmark"
      mkdir -p "$DIR"
      curl -sL "https://raw.githubusercontent.com/aj-may/bookorbit-plugin-shelfmark/main/index.mjs" -o "$DIR/index.mjs"
      chown -R bookorbit:media /var/lib/bookorbit/plugins
      chmod -R 775 /var/lib/bookorbit/plugins
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # 4. SHELFMARK
  services.shelfmark = {
    enable = true; # Działa domyślnie na porcie 8084
    environment = {
      SHELFMARK_DOWNLOAD_DIR = "/data/books";
    };
  };

  # 5. AUDIOBOOKSHELF
  services.audiobookshelf = {
    enable = true;
    host = "0.0.0.0";
    port = 13378;
    group = "media";
  };

  # 6. WSPÓLNE UPRAWNIENIA GRUPY "media" (umask 0002)
  systemd.services = lib.genAttrs
    [ "bookorbit" "shelfmark" "audiobookshelf" ]
    (_: { serviceConfig.UMask = lib.mkForce "0002"; });
}
