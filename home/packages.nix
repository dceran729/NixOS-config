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
    sshfs
    yt-dlp
    ffmpeg
    netcat
    python3

    # --- Aplikacje GUI (Programy użytkowe) ---
    vscode
    dbeaver-bin
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
    (pkgs.symlinkJoin {
      name = "xfburn-wrapped";
      paths = [ pkgs.xfburn ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/xfburn \
          --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${
            pkgs.lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (
              with pkgs.gst_all_1;
              [
                gstreamer
                gst-plugins-base
                gst-plugins-good
                gst-plugins-bad
                gst-plugins-ugly
                gst-libav
              ]
            )
          }"
      '';
    })

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
