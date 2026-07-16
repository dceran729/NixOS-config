{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

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
