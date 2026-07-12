{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    profiles.damian2120 = {
      id = 0;
      isDefault = true;
    };
  };

  home.packages = with pkgs; [
    git
    gh
    micro
    tree
    kdePackages.kate
    discord
    vscode
    fastfetch
    distrobox
    kitty
    alacritty
    fuzzel
    hyprlauncher
    rofi
    hyprlock
    procps
    playerctl
    wev
    lxqt.lxqt-policykit
    nix-output-monitor
  ];
}
