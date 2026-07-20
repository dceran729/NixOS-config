{ config, pkgs, ... }:

{
  xdg.configFile."waybar" = {
    source = ../assets/Waybar-Config;
    recursive = true;
  };

  home.packages = with pkgs; [
    waybar
    playerctl
    impala
    btop
    bluetui
    wiremix
  ];
}
