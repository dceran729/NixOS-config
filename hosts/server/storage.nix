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

    # Pliki z hasłami (EnvironmentFile) - tylko dla roota, poza /nix/store
    "d /var/lib/secrets      0700 root       root  -"

    # Katalogi /var/lib/containers/* NIE są już tworzone: dane usług trzyma
    # teraz każdy moduł w swoim /var/lib/<usługa>. Stary katalog zostaje
    # na dysku jako kopia zapasowa, dopóki go sam nie usuniesz.
  ];
}
