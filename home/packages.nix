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

  # Przeniosłem terminale z "paczki" na "moduł", żeby StyliX mógł je pokolorować!
  programs.alacritty.enable = true;
  programs.kitty.enable = true;

  home.packages = with pkgs; [
    # --- Narzędzia terminalowe i Nixowe ---
    git
    gh
    micro
    tree
    fastfetch
    procps
    distrobox
    nix-search-cli
    nil
    nixd
    nix-tree

    # --- Aplikacje GUI (Programy użytkowe) ---
    vscode
    zed-editor-fhs
    obsidian
    vesktop
    bitwarden-desktop
    blender
    gimp
    gthumb
    vlc
    obs-studio
    mousepad
    google-chrome
    libreoffice
    localsend

    # --- Komponenty środowiska graficznego (Hyprland / Wayland) ---
    fuzzel
    wev
    lxqt.lxqt-policykit
    firefoxpwa
  ];
}
