{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    extraConfig = {
      matching = "fuzzy";
      sort = true;
      sorting-method = "fzf";
      # TA LINIJKA ROBI ROBOTĘ:
      # Rofi będzie szukać wpisanych liter TYLKO w nazwie aplikacji
      # (i ewentualnie nazwie ogólnej, np. "Przeglądarka internetowa")
      drun-match-fields = "name,generic";
    };
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
