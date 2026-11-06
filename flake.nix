{
  description = "Moja wlasna konfiguracja NixOS";

  inputs = {
    # Używamy wersji unstable, bo Hyprland/Niri tam działają najlepiej
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager używa tych samych pakietów co system
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      nixosConfigurations = {

        # Laptop (Hyprland, Home Manager, Stylix - moduły podpina hosts/laptop)
        DCNIX = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/laptop/default.nix ];
        };

        # Serwer: lekka instalacja, bez środowiska graficznego
        DCSRW = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/server/default.nix ];
        };

      };
    };
}
