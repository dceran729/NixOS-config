{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./rofi.nix
    ./waybar.nix
    ./hyprland.nix
    ./ghostty.nix
    ./theme.nix
  ];

  programs.bash.enable = true;

  fonts.fontconfig.enable = true;

  home.username = "damian2120";
  home.homeDirectory = "/home/damian2120";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.shellAliases = {
    r = "sudo true && cd ~/NixOS-config && git add . && sudo nixos-rebuild switch --flake . |& nom && cd ~";
    ns = "nix run github:OleMussmann/Nix-Package-Search --";
    # Możesz tu od razu dodać inne przydatne skróty, na przykład:
    # update = "cd ~/NixOS-config && nix flake update && git add . && sudo nixos-rebuild switch --flake .";
    # ll = "ls -la";
  };
}
