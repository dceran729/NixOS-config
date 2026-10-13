{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./rofi.nix
    ./waybar.nix
    ./hyprland.nix
    ./ghostty.nix
    ./theme.nix
    ./desktop_entries.nix
    ./scripts.nix
    ./walker.nix
    ./zed.nix
  ];

  programs.bash.enable = true;

  fonts.fontconfig.enable = true;

  home.username = "damian2120";
  home.homeDirectory = "/home/damian2120";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.shellAliases = {
    r = "git -C ~/NixOS-config add . && nh os test";
    rs = ''git -C ~/NixOS-config add . && if ! git -C ~/NixOS-config diff --staged --quiet; then git -C ~/NixOS-config commit -m "Aktualizacja: $(date '+%Y-%m-%d %H:%M:%S')" && git -C ~/NixOS-config push; fi && nh os switch'';
    rs-srw = ''git -C ~/NixOS-config add . && if ! git -C ~/NixOS-config diff --staged --quiet; then git -C ~/NixOS-config commit -m "Aktualizacja serwera: $(date '+%Y-%m-%d %H:%M:%S')"; fi && nixos-rebuild switch --flake ~/NixOS-config#DCSRW --target-host damian2120@192.168.1.21 --sudo --ask-sudo-password'';
    ssh-srw = ''ssh damian2120@192.168.1.21'';
  };
}
