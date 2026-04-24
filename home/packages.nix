{ config, pkgs, ... }:

{
  programs.firefox.enable=true;

  environment.systemPackages = with pkgs; [
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
