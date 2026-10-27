{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ iw wpa_supplicant dhcpcd ];

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

    ".config/Scripts/launcher.sh" = {
      source = ../assets/Scripts/launcher.sh;
      executable = true;
    };

    ".config/Scripts/powermenu.sh" = {
      source = ../assets/Scripts/powermenu.sh;
      executable = true;
    };

    ".config/Scripts/launch-walker.sh" = {
      source = ../assets/Scripts/launch-walker.sh;
      executable = true;
    };

    ".config/Scripts/eduroam.sh" = {
      source = ../assets/Scripts/eduroam.sh;
      executable = true;
    };

    ".config/Scripts/codebase.sh" = {
      source = ../assets/Scripts/codebase.sh;
      executable = true;
    };
    # KLUCZOWE: Plik konfiguracyjny znoszący limit 5% i włączający tekst procentów
    ".config/swayosd/config.toml" = {
      source = ../assets/SwayOSD/config.toml;
    };

    ".config/swayosd/style.css" = {
      source = ../assets/SwayOSD/style.css;
    };
  };
}
