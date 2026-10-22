{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../core/default.nix

  ];
  boot.kernelModules = [ "pkcs8_key_parser" ]; # ????????
  system.stateVersion = "25.11";
}
