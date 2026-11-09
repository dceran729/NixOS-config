{ lib, pkgs, ... }:

let
  scripts = builtins.filter (name: lib.hasSuffix ".sh" name)
    (builtins.attrNames (builtins.readDir ./.));
in
{
  home.packages =
    (map (name: pkgs.writeShellScriptBin name (builtins.readFile ./${name})) scripts)
    ++ (with pkgs; [ iw wpa_supplicant dhcpcd ]);
}
