{ config, pkgs, ... }:

{
  programs.hyprland = {
  enable = true;
  withUWSM = false;
  };
}
