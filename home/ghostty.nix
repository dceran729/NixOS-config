{ config, pkgs, ... }:

{
  xdg.configFile."ghostty" = {
    source = ../assets/Ghostty-Config;
    recursive = true;
  };

    home.packages = with pkgs; [
    ghostty
  ];
}
