{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  # 1. ZMIANA NAZWY SERWERA:
  networking.hostName = "DCSRW";

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # 2. ZMIANA ZAUFANEGO UŻYTKOWNIKA NA TWOJEGO:
  nix.settings.trusted-users = [ "root" "damian2120" ];

  # 3. TWORZENIE TWOJEGO KONTA (Tak samo jak na głównym PC):
  users.users.damian2120 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "tymczasowe_haslo"; # Zmień na swoje, wpiszesz je przy pierwszym logowaniu
  };

  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  system.stateVersion = "25.11";
}
