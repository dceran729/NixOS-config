{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    extraConfig = builtins.readFile ./hyprland.lua;
  };
  home.packages = with pkgs; [
    hyprlauncher
    hyprlock
  ];
}
