{ config, pkgs, ... }:

{
  stylix.targets.firefox.profileNames = [ "damian2120" ];
  stylix.targets.qt.platform = "qtct";

  # Integracja z motywami GTK i dodanie Twoich ikon Papirus
  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
}
