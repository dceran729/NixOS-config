{ config, lib, pkgs, ... }:

let
  # ==========================================
  # PLUGIN SHELFMARK DLA BOOKORBITA
  # ==========================================
  # Fork esreddy2, przypięty do konkretnego commita (nic nie zmieni się samo).
  #
  # Przed zmianą commita policz nowy hash:
  #   nix store prefetch-file --json https://raw.githubusercontent.com/esreddy2/bookorbit-plugin-shelfmark/<COMMIT>/index.mjs
  #
  # Plugin działa wewnątrz procesu BookOrbita i zna klucz API Shelfmarka,
  # więc po każdej zmianie commita przejrzyj index.mjs.
  shelfmarkPluginRev = "719358b8ceca6deb76d994b302e91d5f0f8748ae";

  shelfmarkPluginSrc = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/esreddy2/bookorbit-plugin-shelfmark/${shelfmarkPluginRev}/index.mjs";
    hash = "sha256-RnnW8TAtlOPN0+wfrcMDRChM56oE1fa8+TW06MzunSE=";
  };

  # Przełącznik łatki. Ustaw na false, jeśli kiedyś wtyczka sama poradzi
  # sobie z tytułami z LibGena (np. po zmianie commita).
  patchLibgenTitles = true;

  # Łatka: LibGen dokleja do tytułów śmieci w stylu "b f 5602803", przez co
  # funkcja dopasowania tytułu w pluginie odrzuca wszystkie wydania
  # (title_mismatch). Łatka obcina ten ogon tylko na potrzeby porównania.
  # --replace-fail przerwie build, jeśli kod pluginu wygląda inaczej.
  shelfmarkPluginPatched = pkgs.runCommand "bookorbit-shelfmark-index.mjs" { } ''
    cp ${shelfmarkPluginSrc} $out
    chmod +w $out
    substituteInPlace $out \
      --replace-fail "const relTitle = rel.title" "const relTitle = stripReleaseJunk(rel.title)"
    cat >> $out <<'EOF'

    function stripReleaseJunk(t) {
      return String(t || "").replace(/\s+b\s+f\s+\d+\s*$/i, "");
    }
    EOF
    grep -q stripReleaseJunk $out
  '';

  shelfmarkPlugin = if patchLibgenTitles then shelfmarkPluginPatched else shelfmarkPluginSrc;

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

      # Przy każdym starcie BookOrbita wgrywamy przypiętą (i załataną) wersję
      # pluginu. Prefiks "+" uruchamia komendę jako root, poza ograniczeniami
      # usługi (ProtectSystem itp.), więc zapis do /var/lib działa zawsze.
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
