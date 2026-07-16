{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    # Tutaj przenosisz to, co miałeś w swoim pliku konfiguracyjnym w folderze assets
    settings = {
      window-padding-x = 10;
      window-padding-y = 10;
      # StyliX automatycznie dorzuci tutaj kolory i czcionki!
    };
  };
}
