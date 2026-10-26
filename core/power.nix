{ config, pkgs, ... }:
{
  # Przeniesione z hardware.nix
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 16 * 1024;
  } ];

  boot.resumeDevice = "/dev/disk/by-uuid/3678fae2-8986-49dd-a822-13500c34c286";
  boot.kernelParams = [ "resume_offset=16786688" ];

  services.power-profiles-daemon.enable = true;

  # ROZWIĄZANIE BŁĘDU ZAMRAŻANIA (systemd v256+)
  systemd.services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
  systemd.services.systemd-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
  systemd.services.systemd-suspend-then-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";

  services.logind.settings.Login = {
    HandlePowerKey = "suspend-then-hibernate";
    HandleLidSwitch = "suspend-then-hibernate";
    IdleAction = "suspend-then-hibernate";
    IdleActionSec = "20m";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "1h";
  };
}
