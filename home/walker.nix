{ config, pkgs, ... }:

{
  home.packages = [ pkgs.walker ];

  xdg.configFile."walker/config.toml".source = ../assets/Walker/config.toml;
  xdg.configFile."walker/custom/style.css".source = ../assets/Walker/custom.css;
  xdg.configFile."elephant/elephant.toml".text = ''
    # Hyprland startuje bez UWSM, więc prefiks "systemd-run --user" gubi środowisko
    # i polecenia typu wl-copy nie działają.
    auto_detect_launch_prefix = false
  '';

  systemd.user.services.walker = {
    Unit = {
      Description = "Walker (usługa w tle)";
      After = [ "graphical-session.target" "elephant.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      # tryb usługi przyspiesza otwieranie Walkera
      ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
