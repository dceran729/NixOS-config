{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.desktopManager.xterm.enable = false;
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Usługi niezbędne dla Thunara (Kosz, montowanie dysków, miniatury)
  services.gvfs.enable = true;
  services.tumbler.enable = true;
}
