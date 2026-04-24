{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    kdePackages.qtdeclarative
    kdePackages.qtsvg
  ];
}
