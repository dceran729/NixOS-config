{ config, pkgs, ... }:

{
  console.keyMap = "pl2";
  services.xserver.xkb = {
      layout = "pl";
      variant = "";
    };
}
