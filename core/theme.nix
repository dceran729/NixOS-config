{ pkgs, ... }:

{
  # Włączamy Stylixa
  stylix.enable = true;

  # Stylix WYMAGA podania ścieżki do tapety (możesz dać tam cokolwiek, np. z Twojego katalogu assets)
  stylix.image = ../assets/Hyprland-Config/twoja_tapeta.jpg;

  # Wybieramy jeden główny motyw z paczki base16-schemes (np. bardzo popularny catppuccin)
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

  # To rozwiąże problem białego Thunara i brzydkich ikon
  stylix.cursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  # Możesz też zdefiniować fonty dla całego systemu w jednym miejscu
  stylix.fonts = {
    monospace = {
      package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
      name = "JetBrainsMono Nerd Font";
    };
    sansSerif = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans";
    };
  };
}
