{ config, pkgs, ... }:

{
  # Grupa "media" współdzielona przez wszystkie usługi i Twoje konto
  users.groups.media = {
    gid = 999;
  };

  systemd.tmpfiles.rules = [
    # GŁÓWNE FOLDERY NA PLIKI
    "d /data                 0775 root       media -"
    "d /data/torrents        0775 root       media -"
    "d /data/torrents/filmy  0775 root       media -"
    "d /data/torrents/seriale 0775 root      media -"
    "d /data/media           0775 root       media -"
    "d /data/media/filmy     0775 root       media -"
    "d /data/media/seriale   0775 root       media -"
    "d /data/syncthing       0775 damian2120 media -"
    "d /data/media/ksiazki       0775 root media -"
    "d /data/media/audiobooki    0775 root media -"
    "d /data/books               0775 root media -"
    "d /data/bookdock        2775 root media -"
    "d /data/shelfmark       2775 root media -"

    # KATALOGI PLUGINÓW BOOKORBITA
    # Katalog główny BookOrbita zarządza jego moduł, więc tu go tylko
    # zakładamy, jeśli nie istnieje, bez zmiany właściciela i uprawnień ("-").
    # Sam plik pluginu wgrywa books.nix (ExecStartPre w bookorbit.service).
    "d /var/lib/bookorbit                           -    -         -     -"
    "d /var/lib/bookorbit/plugins                   0775 bookorbit media -"
    "d /var/lib/bookorbit/plugins/indexers          0775 bookorbit media -"
    "d /var/lib/bookorbit/plugins/indexers/shelfmark 0775 bookorbit media -"

    # Pliki z hasłami (EnvironmentFile) - tylko dla roota, poza /nix/store
    "d /var/lib/secrets      0700 root       root  -"
  ];
}
