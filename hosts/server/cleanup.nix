{ config, lib, pkgs, ... }:

{
  # Automatyczne sprzątanie starych wersji systemu i pakietów (raz w tygodniu).
  # Serwer nie miał dotąd żadnego GC: "nh clean" jest tylko w konfiguracji
  # laptopa (home-manager), więc każde wdrożenie zostawiało stare wersje.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Deduplikacja identycznych plików w /nix/store
  nix.optimise.automatic = true;

  # Mniej wpisów rozruchowych (każdy trzyma starą wersję systemu na dysku)
  boot.loader.systemd-boot.configurationLimit = 10;

  # Dziennik systemowy: maksymalnie 500 MB
  environment.etc."systemd/journald.conf.d/10-limit.conf".text = ''
    [Journal]
    SystemMaxUse=500M
  '';

  # Podman: co tydzień usuwa nieużywane (osierocone) obrazy i kontenery
  virtualisation.podman.autoPrune = {
    enable = true;
    dates = "weekly";
  };
}
