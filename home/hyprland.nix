{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    # Ta linijka bierze Twój stary plik i "wkleja" go prosto do konfiguracji Nixa:
    extraConfig = builtins.readFile ../assets/Hyprland-Config/hyprland.conf;
  };
  home.packages = with pkgs; [
    hyprlauncher
    hyprlock
  ];
}
