{ config, pkgs, ... }:

{
  home.packages = [ pkgs.walker ];

  xdg.configFile."walker/config.toml".source = ../assets/Walker/config.toml;
  xdg.configFile."walker/custom/style.css".source = ../assets/Walker/custom.css;

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
