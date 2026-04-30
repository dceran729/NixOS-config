{ config, pkgs, ... }:

{
  xdg.configFile."hypr" = {
    source = ../assets/Hyprland-Config;
    recursive = true;
  };

    home.packages = with pkgs; [
  ];
}
