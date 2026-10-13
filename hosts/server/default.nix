# ... (góra pliku bez zmian) ...

  # 1. NAPRAWA BŁĘDU Z BRAKIEM ZAUFANIA (pozwala na zdalne wdrażanie):
  nix.settings.trusted-users = [ "root" "dcser" ];

  # 2. NOWA SKŁADNIA MAGII KLAPY (zamiast services.logind.lidSwitch = ...):
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  system.stateVersion = "24.05"; # Zostaje na dole bez zmian
}
