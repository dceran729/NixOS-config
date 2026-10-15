{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./storage.nix
    ./network.nix
    ./media.nix
  ];

  networking.hostName = "DCSRW";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  environment.systemPackages = with pkgs; [
      ghostty.terminfo
    ];

  nix.settings.trusted-users = [ "root" "damian2120" ];

  # TWOJE KONTO (dodano dostęp do grup video i render dla QuickSync!)
  users.users.damian2120 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "media" "video" "render" ];
  };

  # ---------------------------------------------------
  # INTEL QUICKSYNC (Akceleracja sprzętowa)
  # ---------------------------------------------------
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver   # Główny, najnowszy sterownik dla Intel 12th Gen (iHD)
      intel-vaapi-driver   # Zapasowy sterownik dla starszych API (i965)
      libvdpau-va-gl
    ];
  };

  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  system.stateVersion = "25.11";
}
