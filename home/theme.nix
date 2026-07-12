{ config, pkgs, ... }:

{
   stylix.targets.waybar.enable = false;
   stylix.targets.rofi.enable = false;
   stylix.targets.firefox.profileNames = [ "damian2120" ];
   stylix.targets.qt.platform = "qtct";

      gtk = {
   enable = true;
   gtk4.theme = config.gtk.theme; # To zachowuje stare zachowanie (zalecane przy Stylix)
   };
}
