{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    extraConfig = builtins.readFile ../assets/Hyprland-Config/hyprland.lua;
  };
  home.packages = with pkgs; [
    hyprlauncher
    hyprlock
  ];
}
