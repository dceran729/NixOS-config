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

  # Przełącznik łatki tytułów. Ustaw na false, jeśli kiedyś wtyczka sama
  # poradzi sobie z tytułami z LibGena (np. po zmianie commita).
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

  # ==========================================
  # ŁATKA BOOKORBITA: POBIERANIE Z LOKALNEGO SHELFMARKA
  # ==========================================
  # BookOrbit celowo blokuje pobieranie plików z adresów prywatnych
  # (ALLOW_PRIVATE = false w direct-download.service.js), a ustawienie
  # "Allow private addresses" na indekserze go nie dotyczy. Wtyczka oddaje
  # plik spod http://127.0.0.1:8084/api/localdownload, więc łatka zezwala
  # TYLKO na ten jeden adres (protokół, host, port i ścieżka). Reszta sieci
  # prywatnej dalej jest zablokowana.
  # Build przerwie się, jeśli kod w paczce wygląda inaczej (die / test).
  patchBookorbitDirect = true;

  bookorbitDirectPatch = ''
    f=$out/lib/dist/modules/book-request/fulfillment/direct-download.service.js
    test -f "$f"
    chmod u+w "$f"

    cat > "$TMPDIR/allow-shelfmark.pl" <<'PERL'
    s/const ALLOW_PRIVATE = false;/const ALLOW_PRIVATE = false;\nfunction allowShelfmark(u) { try { const p = new URL(String(u)); return p.protocol === "http:" && p.hostname === "127.0.0.1" && p.port === "8084" && p.pathname === "\/api\/localdownload"; } catch (e) { return false; } }/ or die "definicja";
    s/ensureSafeUrl\)\((release\.fileUrl|download\.directUrl),(\s*\{\s*allowPrivate:\s*)ALLOW_PRIVATE/ensureSafeUrl)($1,$2allowShelfmark($1)/g or die "add/resume";
    s/(ensureSafeUrl\)\()(new URL\(location, current\)\.href)(,\s*\{\s*allowPrivate:\s*)ALLOW_PRIVATE/$1$2$3allowShelfmark($2)/ or die "przekierowanie";
    s/allowPrivate:\s*ALLOW_PRIVATE,(\s*profile: null)/allowPrivate: allowShelfmark(url.href),$1/ or die "safeFetch";
    PERL

    perl -0pi "$TMPDIR/allow-shelfmark.pl" "$f"

    if grep -q "allowPrivate: ALLOW_PRIVATE" "$f"; then
      echo "łatka niepełna: zostało użycie ALLOW_PRIVATE" >&2
      exit 1
    fi
    test "$(grep -c allowShelfmark "$f")" -eq 5
  '';
in
{
  # ==========================================
  # PACZKA BOOKORBITA Z ŁATKĄ (overlay)
  # ==========================================
  nixpkgs.overlays = lib.optional patchBookorbitDirect (final: prev: {
    bookorbit = prev.bookorbit.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.perl ];
      postFixup = (old.postFixup or "") + bookorbitDirectPatch;
    });
  });

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
