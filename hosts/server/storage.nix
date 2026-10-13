{ config, pkgs, ... }:

{
  # Tworzymy grupę "media", która będzie współdzielona przez Ciebie i kontenery
  users.groups.media = {
    gid = 999;
  };

  # Deklaratywne tworzenie struktury katalogów na dysku
  systemd.tmpfiles.rules = [
    "d         /data                        0775         root        media  -"
    "d         /data/torrents               0775         root        media  -"
    "d         /data/torrents/filmy         0775         root        media  -"
    "d         /data/torrents/seriale       0775         root        media  -"
    "d         /data/media                  0775         root        media  -"
    "d         /data/media/filmy            0775         root        media  -"
    "d         /data/media/seriale          0775         root        media  -"

    # Katalog na konfiguracje aplikacji
    "d         /var/lib/containers          0755         root        root   -"
  ];
}
