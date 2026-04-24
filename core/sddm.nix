{ config, pkgs, ... }:

let
  # Przygotowujemy nasz lokalny motyw
  SDDM-Theme = pkgs.stdenv.mkDerivation {
    name = "SDDM-Theme";
    # Zauważ ścieżkę: cofamy się dwa foldery w górę (do roota) i wchodzimy w assets
    src = ../../assets/themes/SDDM-Theme; 
    installPhase = ''
      mkdir -p $out/share/sddm/themes/SDDM-Theme
      cp -r ./* $out/share/sddm/themes/SDDM-Theme/
    '';
  };
in
{
  # Odpalamy SDDM i podpinamy motyw
  services.displayManager.sddm = {
    enable = true;
    theme = "${SDDM-Theme}";
  };
}
