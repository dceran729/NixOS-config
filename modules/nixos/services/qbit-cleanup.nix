{ config, pkgs, ... }:

{
  systemd.services.qbit-cleanup = {
    description = "Usuwa martwe torrenty przez Sonarr/Radarr (blocklist + ponowne wyszukiwanie)";
    after = [ "qbittorrent.service" "sonarr.service" "radarr.service" ];
    path = [
      pkgs.curl
      pkgs.jq
      pkgs.coreutils
    ];

    serviceConfig = {
      Type = "oneshot";
      # Plik /var/lib/secrets/qbit-cleanup.env (chmod 600, własność roota):
      #   QBIT_USER=...
      #   QBIT_PASS=...
      #   SONARR_API_KEY=...   (Sonarr -> Settings -> General -> API Key)
      #   RADARR_API_KEY=...   (Radarr -> Settings -> General -> API Key)
      EnvironmentFile = "/var/lib/secrets/qbit-cleanup.env";
    };

    script = ''
      QBIT_URL="http://127.0.0.1:8080"
      SONARR_URL="http://127.0.0.1:8989"
      RADARR_URL="http://127.0.0.1:7878"

      # metaDL: brak metadanych dłużej niż 2 min od dodania
      # stalledDL: brak jakiejkolwiek aktywności od 2 min
      META_TIMEOUT=300
      STALL_TIMEOUT=180
      # Minimalna liczba węzłów DHT, poniżej której qBit uznajemy za "jeszcze się rozkręca"
      MIN_DHT_NODES=10

      COOKIE_JAR=$(mktemp)
      trap 'rm -f "$COOKIE_JAR"' EXIT

      curl -s -c "$COOKIE_JAR" \
        --data-urlencode "username=$QBIT_USER" \
        --data-urlencode "password=$QBIT_PASS" \
        "$QBIT_URL/api/v2/auth/login" > /dev/null

      DHT=$(curl -sf -b "$COOKIE_JAR" "$QBIT_URL/api/v2/transfer/info" | jq -r '.dht_nodes // 0')
      if [ "''${DHT:-0}" -lt "$MIN_DHT_NODES" ]; then
        echo "DHT niegotowe ($DHT węzłów), pomijam czyszczenie"
        curl -s -b "$COOKIE_JAR" "$QBIT_URL/api/v2/auth/logout" > /dev/null
        exit 0
      fi

      JSON=$(curl -sf -b "$COOKIE_JAR" "$QBIT_URL/api/v2/torrents/info") || {
        echo "Nie udało się pobrać listy torrentów z qBittorrenta"
        exit 1
      }
      NOW=$(date +%s)

      HASHES=$(echo "$JSON" | jq -r \
        --argjson now "$NOW" \
        --argjson meta "$META_TIMEOUT" \
        --argjson stall "$STALL_TIMEOUT" '
          .[] | select(
            ((.state == "metaDL" or .state == "forcedMetaDL") and ($now - .added_on > $meta))
            or
            (.state == "stalledDL" and ($now - ([.added_on, .last_activity] | max) > $stall))
          ) | .hash')

      [ -z "$HASHES" ] && { curl -s -b "$COOKIE_JAR" "$QBIT_URL/api/v2/auth/logout" > /dev/null; exit 0; }

      SONARR_QUEUE=$(curl -sf -H "X-Api-Key: $SONARR_API_KEY" "$SONARR_URL/api/v3/queue?pageSize=1000" || echo '{"records":[]}')
      RADARR_QUEUE=$(curl -sf -H "X-Api-Key: $RADARR_API_KEY" "$RADARR_URL/api/v3/queue?pageSize=1000" || echo '{"records":[]}')

      # Usuwa pozycję z kolejki *arr: kasuje z klienta, dodaje do blocklisty
      # i uruchamia ponowne wyszukiwanie (skipRedownload=false).
      # Argumenty: URL, klucz API, JSON kolejki, hash torrenta
      remove_via_arr() {
        id=$(echo "$3" | jq -r --arg h "$4" \
          '[.records[] | select((.downloadId // "" | ascii_downcase) == ($h | ascii_downcase)) | .id][0] // empty')
        [ -z "$id" ] && return 1
        curl -sf -X DELETE -H "X-Api-Key: $2" \
          "$1/api/v3/queue/$id?removeFromClient=true&blocklist=true&skipRedownload=false" > /dev/null
      }

      for hash in $HASHES; do
        if remove_via_arr "$SONARR_URL" "$SONARR_API_KEY" "$SONARR_QUEUE" "$hash"; then
          echo "Sonarr: usunięto i zablokowano $hash"
        elif remove_via_arr "$RADARR_URL" "$RADARR_API_KEY" "$RADARR_QUEUE" "$hash"; then
          echo "Radarr: usunięto i zablokowano $hash"
        else
          # Torrent nie należy do żadnego *arr (dodany ręcznie) - zwykłe usunięcie
          echo "Brak w kolejce *arr, usuwam bezpośrednio: $hash"
          curl -s -b "$COOKIE_JAR" --data "hashes=$hash&deleteFiles=true" \
            "$QBIT_URL/api/v2/torrents/delete" > /dev/null
        fi
      done

      curl -s -b "$COOKIE_JAR" "$QBIT_URL/api/v2/auth/logout" > /dev/null
    '';
  };

  systemd.timers.qbit-cleanup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "1m";
    };
  };
}
