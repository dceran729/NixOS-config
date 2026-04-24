{ config, pkgs, ... }:

{
imports = [
  ./sddm.nix
  ./grub.nix
  ./audio.nix
  ./keyboard.nix
  ./location.nix
  ./network.nix
  ./packages.nix
  ./users.nix
  ./wayland.nix
  ./system.nix
  ];
}
