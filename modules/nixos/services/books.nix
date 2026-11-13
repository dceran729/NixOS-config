{ config, lib, pkgs, ... }:

let
  # ==========================================
  # PLUGIN SHELFMARK DLA BOOKORBITA
  # ==========================================
  # Fork esreddy2, przypięty do konkretnego commita (nic nie zmieni się samo).
  #
  # 1. Commit sprawdzisz tak:
  #      git ls-remote https://github.com/esreddy2/bookorbit-plugin-shelfmark HEAD
  # 2. Hash policzysz tak (wynik "hash" wklej niżej):
  #      nix store prefetch-file --json https://raw.githubusercontent.com/esreddy2/bookorbit-plugin-shelfmark/<COMMIT>/index.mjs
  #    albo zostaw lib.fakeHash - pierwszy build wypisze prawidłowy.
  # 3. Przed pierwszym użyciem otwórz index.mjs i przejrzyj go: plugin działa
  #    wewnątrz procesu BookOrbita i zna klucz API Shelfmarka. Wyszukaj też
  #    "update" - jeśli ustawienia autoaktualizacji da się wyłączyć w pliku
  #    (README forka podaje "update: null"), napisz, to dopiszę łatkę.
  shelfmarkPluginRev = "<COMMIT>";

  shelfmarkPlugin = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/esreddy2/bookorbit-plugin-shelfmark/${shelfmarkPluginRev}/index.mjs";
    hash = lib.fakeHash;
  };

  # Ścieżka musi zgadzać się z katalogami w storage.nix.
  shelfmarkPluginDir = "/var/lib/bookorbit/plugins/indexers/shelfmark";
in
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
      INGEST_DIR = "/data/shelfmark";   # własny katalog Shelfmarka, NIE Book Dock
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
      # jako dodatkową (zapis do /data/shelfmark).
      shelfmark.serviceConfig = {
        SupplementaryGroups = [ "media" ];
        # ProtectSystem=strict: pozwól zapisywać tylko do własnego katalogu
        ReadWritePaths = [ "/data/shelfmark" ];
      };

      # Przy każdym starcie BookOrbita wgrywamy przypiętą wersję pluginu.
      # Prefiks "+" uruchamia komendę jako root, poza ograniczeniami usługi
      # (ProtectSystem itp.), więc zapis do /var/lib działa zawsze.
      bookorbit.serviceConfig.ExecStartPre = [
        "+${pkgs.coreutils}/bin/install -D -m 0644 -o bookorbit -g media ${shelfmarkPlugin} ${shelfmarkPluginDir}/index.mjs"
      ];

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
