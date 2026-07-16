{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  environment.systemPackages = with pkgs; [
    #SDDM-Theme
    kdePackages.qtdeclarative
    kdePackages.qtsvg

    #Hyprland-dependancies
    brightnessctl
    playerctl
    wireplumber

    #waybar stuff
    waybar

    nix-output-monitor
    ffmpeg
  ];
}
