{ pkgs, ... }:

{
  xdg.dataFile = {
    "applications/rofi-theme-selector.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Rofi Theme
      NoDisplay=true
    '';

    "applications/rofi.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Rofi
      NoDisplay=true
    '';

    "applications/kvantummanager.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Kvantum
      NoDisplay=true
    '';

    "applications/btop.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=btop
      NoDisplay=true
    '';

    "applications/xterm.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=xterm
      NoDisplay=true
    '';

    "applications/nixos-manual.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=NixOS Manual
      NoDisplay=true
    '';

    "applications/qt5ct.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Qt5
      NoDisplay=true
    '';

    "applications/qt6ct.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Qt6
      NoDisplay=true
    '';

    "applications/thunar-bulk-rename.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Bulk Rename
      NoDisplay=true
    '';

    "applications/thunar-settings.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Thunar Settings
      NoDisplay=true
    '';

    "applications/firefoxpwa.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Thunar Settings
      NoDisplay=true
    '';

    "applications/thunar-volman-settings.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Removable Drives and Media
      NoDisplay=true
    '';

    "applications/vesktop.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Discord
      Icon=discord
      Exec=vesktop %U
    '';
  };
}
