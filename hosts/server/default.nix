{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./storage.nix
    ./network.nix
    ./cleanup.nix

    ../../modules/nixos/common
    ../../modules/nixos/services/media.nix
    ../../modules/nixos/services/qbit-cleanup.nix
    ../../modules/nixos/services/caddy.nix
  ];

  networking.hostName = "DCSRW";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  environment.systemPackages = with pkgs; [
    ghostty.terminfo
  ];

  nix.settings.trusted-users = [
    "root"
    "damian2120"
  ];

  # Konto (isNormalUser, wheel, networkmanager) jest w modules/nixos/common/user.nix.
  # Tutaj tylko dodatkowe grupy (video i render dla QuickSync!)
  users.users.damian2120.extraGroups = [
    "media"
    "video"
    "render"
  ];

  # ---------------------------------------------------
  # INTEL QUICKSYNC (Akceleracja sprzętowa)
  # ---------------------------------------------------
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # Główny, najnowszy sterownik dla Intel 12th Gen (iHD)
      intel-vaapi-driver # Zapasowy sterownik dla starszych API (i965)
      libvdpau-va-gl
    ];
  };

  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  system.stateVersion = "25.11";
}
