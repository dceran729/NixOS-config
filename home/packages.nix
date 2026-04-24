{ config, pkgs, ... }:

{
  programs.firefox.enable=true;

  home.packages = with pkgs; [
    git
    gh
    micro
    tree
    kdePackages.kate
    discord
    vscode
    neofetch

  ];
}
