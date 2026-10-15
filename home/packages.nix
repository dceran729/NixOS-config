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

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 3"; # Automatyczne sprzątanie starych generacji
    flake = "/home/damian2120/NixOS-config"; # Definiuje domyślną ścieżkę do Flake
  };

  # programs.localsend.enable = true;

  services.cliphist.enable = true;
  services.swayosd.enable = true;

  home.packages = with pkgs; [
    # --- Narzędzia terminalowe i Nixowe ---
    git
    gh
    tree
    fastfetch
    procps
    distrobox
    nix-search-cli
    nil
    nixd
    nix-tree
    gcc

    # --- Aplikacje GUI (Programy użytkowe) ---
    vscode
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
    wl-clipboard
    grim
    slurp
    swappy
  ];
}
