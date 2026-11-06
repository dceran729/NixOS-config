{ config, pkgs, ... }:

{
  programs.hyprland = {
  enable = true;
  withUWSM = false;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*"; # Ważne na Hyprlandzie
  };
}
