{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  environment.systemPackages = with pkgs; [
    kdePackages.qtdeclarative
    kdePackages.qtsvg
  ];
}
