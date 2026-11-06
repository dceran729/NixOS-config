{ config, pkgs, ... }:

{
  xdg.configFile."waybar/config.jsonc".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = ./style.css;

  home.packages = with pkgs; [
    waybar
    playerctl
    impala
    btop
    bluetui
    wiremix
  ];
}
