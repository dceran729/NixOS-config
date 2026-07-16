{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
  };

  xdg.configFile."rofi" = {
    source = ../assets/Rofi-Theme/files;
    recursive = true;
  };

  home.file.".local/share/fonts" = {
    source = ../assets/Rofi-Theme/fonts;
    recursive = true;
  };
}
