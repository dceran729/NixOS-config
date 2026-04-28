{ config, pkgs, ... }:

{
  # 1. Instalacja Rofi (pamiętaj o wersji Wayland, jeśli używasz Hyprlanda)
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
  };

  # 2. Mapowanie plików konfiguracyjnych
  xdg.configFile."rofi" = {
    source = ../assets/Rofi-Theme/files;
    recursive = true;
  };

  # 3. Instalacja czcionek z Twojego folderu assets
  # Dzięki temu ikony w Rofi nie będą "kwadracikami"
  home.file.".local/share/fonts" = {
    source = ../assets/Rofi-Theme/fonts;
    recursive = true;
  };
}
