{ config, pkgs, ... }:

{
  home.file = {
    # Skrypt jasności
    ".config/Scripts/brightness.sh" = {
      source = ../assets/Scripts/brightness.sh;
      executable = true;
    };

    ".config/Scripts/mic.sh" = {
      source = ../assets/Scripts/mic.sh;
      executable = true;
    };

    # KLUCZOWE: Plik konfiguracyjny znoszący limit 5% i włączający tekst procentów
    ".config/swayosd/config.toml" = {
      source = ../assets/SwayOSD/config.toml;
    };
  };
}
