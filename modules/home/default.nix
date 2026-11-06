{ config, pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./packages.nix
    ./theme.nix
    ./desktop-entries.nix
    ./ghostty.nix
    ./zed.nix
    ./lock.nix
    ./hyprland
    ./waybar
    ./rofi
    ./walker
    ./swayosd
    ./scripts
  ];

  fonts.fontconfig.enable = true;

  home.username = "damian2120";
  home.homeDirectory = "/home/damian2120";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
