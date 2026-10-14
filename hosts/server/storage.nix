{ config, pkgs, ... }:

{
  # Tworzymy grupę "media", która będzie współdzielona przez Ciebie i kontenery
  users.groups.media = {
    gid = 999;
  };

  # Deklaratywne tworzenie struktury katalogów na dysku
  systemd.tmpfiles.rules = [
    # GŁÓWNE FOLDERY NA PLIKI
    "d         /data                        0775         root        media  -"
    "d         /data/torrents               0775         root        media  -"
    "d         /data/torrents/filmy         0775         root        media  -"
    "d         /data/torrents/seriale       0775         root        media  -"
    "d         /data/media                  0775         root        media  -"
    "d         /data/media/filmy            0775         root        media  -"
    "d         /data/media/seriale          0775         root        media  -"

    # KATALOGI NA KONFIGURACJE APLIKACJI
    "d         /var/lib/containers              0755         root        root   -"

    # Podfoldery dla każdego kontenera (z prawami zapisu dla Ciebie - damian2120)
    "d         /var/lib/containers/qbittorrent  0775         damian2120  media  -"
    "d         /var/lib/containers/radarr       0775         damian2120  media  -"
    "d         /var/lib/containers/sonarr       0775         damian2120  media  -"
    "d         /var/lib/containers/prowlarr     0775         damian2120  media  -"
    "d         /var/lib/containers/jellyseerr   0775         damian2120  media  -"
    "d         /var/lib/containers/homepage     0775         damian2120  media  -"
    "d         /var/lib/containers/uptimekuma   0775         damian2120  media  -"
    "d         /var/lib/containers/bazarr       0775         damian2120  media  -"
  ];
}
