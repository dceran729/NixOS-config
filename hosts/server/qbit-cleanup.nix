{ config, pkgs, ... }:

{
  systemd.services.qbit-cleanup = {
    description = "Usuwa martwe torrenty z qBittorrenta by wymusic pobranie kolejnych w Radarr";
    path = [ pkgs.curl pkgs.jq pkgs.coreutils ];
    script = ''
      COOKIE_JAR=$(mktemp)
      QBIT_URL="http://100.95.221.38:8080"

      USER="DCSRW"
      PASS="qwe321"

      curl -s -c "$COOKIE_JAR" --data "username=$USER&password=$PASS" "$QBIT_URL/api/v2/auth/login" > /dev/null
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
