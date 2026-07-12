{ config, pkgs, ... }:

let
  # Przygotowujemy nasz lokalny motyw
  SDDM-Theme = pkgs.stdenv.mkDerivation {
    name = "SDDM-Theme";
    src = ../assets/SDDM-Theme;

    installPhase = ''
      mkdir -p $out/share/sddm/themes/SDDM-Theme
      cp -r ./* $out/share/sddm/themes/SDDM-Theme/
    '';
  };
in
{
  # Dodajemy motyw do pakietów systemowych
  environment.systemPackages = [ SDDM-Theme ];

  services.displayManager.sddm = {
    enable = true;
    theme = "SDDM-Theme";

    # WYŁĄCZAMY Waylanda dla samego ekranu logowania.
    # To zapobiega crashom i zrzucaniu do TTY po wylogowaniu z Hyprlanda.
    wayland.enable = false;

    # Biblioteki Qt niezbędne do poprawnego renderowania Twojego motywu QML
    extraPackages = with pkgs.kdePackages; [
      qtsvg        # Obsługa ikon i grafik SVG w motywie
      qt5compat    # Kompatybilność wsteczna dla elementów QML
    ];
  };
}
