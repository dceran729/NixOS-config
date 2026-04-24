{ config, pkgs, ... }:

let
  Grub-Theme = pkgs.stdenv.mkDerivation {
    name = "Grub-Theme";
    src = ../assets/Grub-Theme;
    
    installPhase = ''
      # Tworzymy główny folder w Nix Store
      mkdir -p $out
      # Kopiujemy do niego całą zawartość motywu (tam, gdzie jest theme.txt)
      cp -r ./* $out/
    '';
  };
in
{
  # Podpinamy motyw do ustawień bootloadera
  boot.loader.grub = {
    enable = true;
    theme = "${Grub-Theme}";
    device = "nodev";
    efiSupport = true;  
  };
  boot.loader.efi.canTouchEfiVariables = true;
}
