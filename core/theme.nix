{ pkgs, ... }:

{
  stylix.enable = true;

  stylix.image = ../assets/Wallpapers/a_woman_sitting_on_a_couch_looking_out_a_window.png;
  stylix.polarity = "dark";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark-dark.yaml";

  stylix.cursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  stylix.targets.grub.enable = false;
}
