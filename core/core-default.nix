{ config, pkgs, ... }:

{
imports = [
  ./sddm.nix
  ./grub.nix
  ./audio.nix
  ./keyboard.nix
  ./locale.nix
  ./network.nix
  ./packages.nix
  ./users.nix
  ./wayland.nix
  ./system.nix
  ./fonts.nix
  ./theme.nix
  ./thunar.nix
  ];
}
