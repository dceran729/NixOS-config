{
  description = "Main Config";

  # 1. WEJŚCIA (Inputs) - tu mówisz Nixowi, skąd brać programy
  inputs = {
    # Używamy gałęzi unstable, bo jest najlepsza dla Hyprlanda i nowych sterowników
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  # 2. WYJŚCIA (Outputs) - tu definiujesz, co ma powstać z tego Flake'a
  outputs = { self, nixpkgs, ... }@inputs: {
    # 'DCNIX' musi być identyczne z Twoim 'networking.hostName' w pliku default.nix
    nixosConfigurations.DCNIX = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; 
      
      # Przekazujemy 'inputs' do środka systemu, żeby inne pliki mogły z nich korzystać
      specialArgs = { inherit inputs; }; 

      modules = [
        # To jest ścieżka do Twojego głównego pliku konfiguracyjnego
        ./hosts/laptop/default.nix
      ];
    };
  };
}
