{ config, pkgs, ... }:

let
  # Przygotowujemy nasz lokalny motyw
  SDDM-Theme = pkgs.stdenv.mkDerivation {
    name = "SDDM-Theme";
    # Ścieżka jest poprawna (krok w tył do roota i wejście w assets)
    src = ../assets/SDDM-Theme;

    installPhase = ''
      mkdir -p $out/share/sddm/themes/SDDM-Theme
      cp -r ./* $out/share/sddm/themes/SDDM-Theme/
    '';
  };
in
{
  # 1. Dodajemy motyw do pakietów systemowych, żeby SDDM go "widział"
  environment.systemPackages = [ SDDM-Theme ];

  # Odpalamy SDDM i podpinamy motyw
  services.displayManager.sddm = {
    enable = true;
    # 2. Podajemy NAZWĘ folderu z motywem, a nie całą ścieżkę (/nix/store/...)
    theme = "SDDM-Theme";
  };
}
