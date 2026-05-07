{ pkgs, ... }:

{
  home.packages = with pkgs; [
    thunar
    thunar-archive-plugin
    thunar-volman

    # --- TO DODAŁEM ---
    xfce4-settings      # Pozwala ustawić motyw/ikony, jeśli nie robisz tego przez Home Managera
    papirus-icon-theme       # Świetny pakiet ikon (Thunar ich potrzebuje!)
    lxappearance             # Proste narzędzie do wybierania motywów GTK
  ];

  xdg.configFile."Thunar".source = ../assets/Thunar-Config;
}
