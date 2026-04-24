{
  description = "Moja wlasna konfiguracja NixOS";

  inputs = {
    # Używamy wersji unstable, bo Hyprland/Niri tam działają najlepiej
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Pobieramy Home Managera i każemy mu używać tych samych pakietów co system
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # Nazwa Twojego hosta to "laptop"
        DCNIX = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; }; # Przekazujemy "inputs" dalej do modułów
        modules = [
          # 1. Ładujemy główny plik Twojego laptopa
          ./hosts/laptop/default.nix

          # 2. Dodajemy Home Managera jako moduł systemu
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # 3. Wskazujemy główny plik konfiguracji Home Managera
            home-manager.users.damian2120 = import ./home/default.nix;
          }
        ];
      };
    };
  };
}
