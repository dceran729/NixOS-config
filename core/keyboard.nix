{ config, pkgs, ... }:

{
  console.keyMap = "pl2"; # klawiatura w konsoli TTY
  vservices.xserver.xkb = {
      layout = "pl";
      variant = "";
    };
}
