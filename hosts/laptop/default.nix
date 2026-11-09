{ inputs, ... }:

{
  imports = [
    inputs.stylix.nixosModules.stylix
    inputs.home-manager.nixosModules.home-manager

    ./hardware.nix
    ./power.nix

    ../../modules/nixos/common
    ../../modules/nixos/desktop
    ../../modules/nixos/services/ollama.nix
  ];

  networking.hostName = "DCNIX";
  boot.kernelModules = [ "pkcs8_key_parser" ]; # ????????

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.damian2120 = import ../../modules/home/default.nix;
  };

  system.stateVersion = "25.11";
}
