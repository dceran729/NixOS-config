{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  programs.firefox.enable=true;

  environment.systemPackages = with pkgs; [
    kdePackages.qtdeclarative
    kdePackages.qtsvg
    git
    gh
    micro
    tree
  ];
}
