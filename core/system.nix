{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;

  # Usługi niezbędne dla Thunara (Kosz, montowanie dysków, miniatury)
  services.gvfs.enable = true;
  services.tumbler.enable = true;
}
