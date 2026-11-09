{ lib, pkgs, ... }:

let
  # Lokalny motyw (cały katalog oprócz default.nix)
  SDDM-Theme = pkgs.stdenv.mkDerivation {
    name = "SDDM-Theme";
    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.difference ./. ./default.nix;
    };

    installPhase = ''
      mkdir -p $out/share/sddm/themes/SDDM-Theme
      cp -r ./* $out/share/sddm/themes/SDDM-Theme/
    '';
  };
in
{
  # Dodajemy motyw do pakietów systemowych
  environment.systemPackages = [
    SDDM-Theme
    pkgs.kdePackages.qtdeclarative
  ];

  services.displayManager.sddm = {
    enable = true;
    theme = "SDDM-Theme";

    # WYŁĄCZAMY Waylanda dla samego ekranu logowania.
    # To zapobiega crashom i zrzucaniu do TTY po wylogowaniu z Hyprlanda.
    wayland.enable = false;

    # Biblioteki Qt niezbędne do poprawnego renderowania motywu QML
    extraPackages = with pkgs.kdePackages; [
      qtsvg        # Obsługa ikon i grafik SVG w motywie
      qt5compat    # Kompatybilność wsteczna dla elementów QML
    ];
  };
}
