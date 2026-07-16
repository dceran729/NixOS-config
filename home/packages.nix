{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    profiles.damian2120 = {
      id = 0;
      isDefault = true;
    };
    nativeMessagingHosts = [ pkgs.firefoxpwa ];
  };

  home.packages = with pkgs; [
    git
    gh
    micro
    tree
    kdePackages.kate
    vscode
    fastfetch
    distrobox
    kitty
    alacritty
    fuzzel
    hyprlauncher
    hyprlock
    procps
    playerctl
    wev
    lxqt.lxqt-policykit
    gthumb
    firefoxpwa
    vesktop
    zed-editor-fhs
    nix-search-cli
    bitwarden-desktop
    bleachbit
    blender
    gimp
    localsend
    vlc
    micro
    obs-studio
    obsidian
    mousepad
    google-chrome
    libreoffice
    nil
    nixd
  ];
}
