{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ./storage.nix
    ./network.nix
    ./cleanup.nix

    ../../modules/nixos/common
    ../../modules/nixos/services/media.nix
    ../../modules/nixos/services/qbit-cleanup.nix
    ../../modules/nixos/services/caddy.nix
    ../../modules/nixos/services/books.nix
    ../../modules/nixos/services/freellmapi.nix
  ];

  networking.hostName = "DCSRW";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  environment.systemPackages = with pkgs; [
    ghostty.terminfo
  ];

  nix.settings.trusted-users = [
    "root"
    "damian2120"
  ];

  # Konto (isNormalUser, wheel, networkmanager) jest w modules/nixos/common/user.nix.
  # Tutaj tylko dodatkowe grupy (video i render dla QuickSync!)
  users.users.damian2120.extraGroups = [
    "media"
    "video"
    "render"
  ];

  programs.fish.interactiveShellInit = lib.mkAfter ''
      set -g fish_greeting

      if functions -q enable_transience
        function starship_transient_prompt_func
          starship module character
        end
        enable_transience
      end
    '';

    programs.starship = {
      enable = true;
      settings = {
        add_newline = true;
        format = "╭─SRW$directory$git_branch$git_status\n╰─$character";

        directory = {
          style = "bold blue";
          truncation_length = 3;
          truncation_symbol = "…/";
        };

        git_branch = {
          symbol = "";
          format = "[on $branch]($style) ";
          style = "bold purple";
        };

        git_status = {
          format = "[$all_status$ahead_behind]($style) ";
          style = "bold yellow";
        };

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
        };
      };
    };

  # ---------------------------------------------------
  # INTEL QUICKSYNC (Akceleracja sprzętowa)
  # ---------------------------------------------------
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # Główny, najnowszy sterownik dla Intel 12th Gen (iHD)
      intel-vaapi-driver # Zapasowy sterownik dla starszych API (i965)
      libvdpau-va-gl
    ];
  };

  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  system.stateVersion = "25.11";
}
