{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  services.elephant.enable = true;

  # Elephant odpala "sh -c wl-copy ..." przy wyborze wpisu ze schowka,
  # a domyślny PATH jego usługi nie ma ani sh, ani wl-copy.
  systemd.user.services.elephant.path = with pkgs; [
    bash          # dostarcza "sh"
    wl-clipboard  # wl-copy
  ];

  environment.systemPackages = with pkgs; [
    # --- Zależności interfejsu (SDDM) ---
    kdePackages.qtdeclarative

    # --- Narzędzia systemowe i multimedialne ---
    brightnessctl # Kontrola jasności z poziomu kernela
    playerctl # Globalna kontrola multimediów (klawisze funkcyjne)
    wireplumber # Serwer sesji audio (niezbędny do działania PipeWire)
    ffmpeg # Biblioteki dekodowania wideo (potrzebne systemowo)
    # --- Narzędzia diagnostyczne ---
    nix-output-monitor # Ładniejsze wyświetlanie postępu budowania (np. polecenie 'nom')
  ];
}
