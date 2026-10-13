{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "server";

  # Zapobiega problemom z wi-fi
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  # Prosty bootloader serwerowy
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Pozwala na zdalne wdrażanie (Twój użytkownik jako zaufany administrator w Nix)
  nix.settings.trusted-users = [ "root" "dcser" ];

  # MAGIA: Zakaz usypiania po zamknięciu klapy ekranu (Nowa składnia)
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  system.stateVersion = "25.11"; # Ważne żeby został ten sam, nawet po aktualizacji Flake'a do nowszej wersji
}
