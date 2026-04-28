{ config, pkgs, ... }:

{
  # 1. Importujemy Twoje rozbite pliki konfiguracyjne z folderu home
  imports = [
    ./packages.nix
    ./rofi.nix
    # Poniższe linie są zakomentowane. Odkomentuj je (usuń #),
    # gdy będziesz gotowy na wczytanie konfiguracji tych środowisk:
    # ./hyprland
    # ./niri
  ];




  home.username = "damian2120";
  home.homeDirectory = "/home/damian2120";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
