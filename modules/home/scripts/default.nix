{ lib, pkgs, ... }:

let
  scripts = [
    "brightness.sh"
    "mic.sh"
    "launcher.sh"
    "powermenu.sh"
    "launch-walker.sh"
    "eduroam.sh"
    "codebase.sh"
  ];
in
{
  home.packages = with pkgs; [ iw wpa_supplicant dhcpcd ];

  # Każdy skrypt z tego katalogu ląduje w ~/.config/Scripts/ jako wykonywalny
  home.file = lib.listToAttrs (map (name: {
    name = ".config/Scripts/${name}";
    value = {
      source = ./. + "/${name}";
      executable = true;
    };
  }) scripts);
}
