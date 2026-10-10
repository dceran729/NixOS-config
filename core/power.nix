{ config, pkgs, ... }:
{
  # Przeniesione z hardware.nix
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  } ];

  boot.resumeDevice = "/dev/disk/by-uuid/3678fae2-8986-49dd-a822-13500c34c286";
  # TUTAJ WPISZ LICZBĘ Z POLECENIA WYŻEJ:
  boot.kernelParams = [ "resume_offset=16786688" ];

  services.power-profiles-daemon.enable = true;
  services.logind.lidSwitch = "suspend-then-hibernate";

  services.logind.settings.Login = {
    HandlePowerKey = "suspend-then-hibernate";
    IdleAction = "suspend-then-hibernate";
    IdleActionSec = "20m";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "2h";
  };
}
