{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    walker
    elephant
  ];

  xdg.configFile."walker/config.toml".source = ../assets/Walker/config.toml;
  xdg.configFile."walker/custom/style.css".source = ../assets/Walker/custom.css;

}
