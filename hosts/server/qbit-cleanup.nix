{ config, pkgs, ... }:

{
  systemd.services.qbit-cleanup = {
    description = "Usuwa martwe torrenty z qBittorrenta, by wymusić pobranie kolejnych w Radarr";
    after = [ "qbittorrent.service" ];
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
      EnvironmentFile = "/var/lib/secrets/qbit-cleanup.env";
    };

    script = ''
      COOKIE_JAR=$(mktemp)
      QBIT_URL="http://127.0.0.1:8080"

      curl -s -c "$COOKIE_JAR" --data-urlencode "username=$QBIT_USER" --data-urlencode "password=$QBIT_PASS" "$QBIT_URL/api/v2/auth/login" > /dev/null
      JSON=$(curl -s -b "$COOKIE_JAR" "$QBIT_URL/api/v2/torrents/info")
      NOW=$(date +%s)

      if [ -n "$JSON" ] && [ "$JSON" != "null" ]; then
        HASHES=$(echo "$JSON" | jq -r --argjson now "$NOW" '.[] | select((.state == "metaDL" or .state == "stalledDL") and ($now - .added_on > 900)) | .hash')
        for hash in $HASHES; do
          curl -s -b "$COOKIE_JAR" --data "hashes=$hash&deleteFiles=true" "$QBIT_URL/api/v2/torrents/delete" > /dev/null
        done
      fi

      curl -s -b "$COOKIE_JAR" "$QBIT_URL/api/v2/auth/logout" > /dev/null
      rm -f "$COOKIE_JAR"
    '';
  };

  systemd.timers.qbit-cleanup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
    };
  };
}
