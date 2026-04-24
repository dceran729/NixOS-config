{ config, pkgs, ... }:

{
  imports = [
  ./hardware.nix
  ../../core/core-default.nix

  ];
  system.stateVersion = "25.11";
}
