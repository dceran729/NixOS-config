{ pkgs, ... }:

{
  stylix.enable = true;

  # Główne zasady wyglądu
  stylix.image = ../assets/Wallpapers/a_woman_sitting_on_a_couch_looking_out_a_window.png;
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark-dark.yaml";

  # Kursor
  stylix.cursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  # Blokady - StyliX ma tego NIE tykać, bo masz tam własne motywy w assetach:
  stylix.targets.grub.enable = false;
}
