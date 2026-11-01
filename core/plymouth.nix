{
  boot.plymouth.enable = true;

  stylix.targets.plymouth = {
    logo = ../assets/plymouth-logo.png;   # własne logo PNG
    logoAnimated = false;                 # true = obracające się logo
  };

  boot = {
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [ "quiet" "splash" "udev.log_level=3" "systemd.show_status=auto" ];
  };
}
