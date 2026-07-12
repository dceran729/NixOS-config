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

    # 1. DODAJEMY INPUT STYLIXA
    stylix.url = "github:danth/stylix";
  };

  # 2. PRZEKAZUJEMY STYLIXA DO OUTPUTS
  outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs: {
    nixosConfigurations = {
      # Nazwa Twojego hosta to "laptop"
      DCNIX = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; }; # Przekazujemy "inputs" dalej do modułów
        modules = [
          ./hosts/laptop/default.nix
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Wskazujemy główny plik konfiguracji Home Managera
            home-manager.users.damian2120 = import ./home/default.nix;
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
  };
}
