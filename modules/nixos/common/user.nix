{ config, pkgs, ... }:

{
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    micro
  ];

  environment.variables = {
    EDITOR = "micro";
    VISUAL = "micro";
  };

  users.users.damian2120 = {
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
