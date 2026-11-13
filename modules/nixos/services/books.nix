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
      # Pobrane książki trafiają do Book Dock BookOrbita (folder z storage.nix)
      INGEST_DIR = "/data/bookdock";
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
  # SYSTEMD
  # ==========================================
  systemd.services = lib.mkMerge [
    # Pliki tworzone przez te usługi mają być zapisywalne dla całej grupy
    # "media" (umask 0002) - tak samo jak w media.nix.
    (lib.genAttrs [ "bookorbit" "shelfmark" "audiobookshelf" ] (_: {
      serviceConfig.UMask = lib.mkForce "0002";
    }))

    # Nowe usługi i dodatkowe ustawienia
    {
      # Moduł Shelfmarka nie ma opcji "group", więc dajemy mu grupę media
      # jako dodatkową (zapis do /data/bookdock).
      shelfmark.serviceConfig.SupplementaryGroups = [ "media" ];

      bookorbit-db-setup = {
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
    }
  ];
}
