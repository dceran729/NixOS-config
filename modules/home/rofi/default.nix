{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
  };

  xdg.configFile."rofi" = {
    source = ./files;
    recursive = true;
  };

  home.file.".local/share/fonts" = {
    source = ./fonts;
    recursive = true;
  };
}
