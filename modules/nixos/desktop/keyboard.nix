{ config, pkgs, ... }:

{
  console.keyMap = "pl2"; # klawiatura w konsoli TTY
  services.xserver.xkb = {
      layout = "pl";
      variant = "";
    };
}
