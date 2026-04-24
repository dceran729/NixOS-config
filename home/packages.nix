{ config, pkgs, ... }:

{
  programs.firefox.enable=true;
  programs.firefox.configPath = ".mozilla/firefox";

  home.packages = with pkgs; [
    git
    gh
    micro
    tree
    kdePackages.kate
    discord
    vscode
    fastfetch

  ];
}
