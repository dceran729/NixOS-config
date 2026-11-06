#!/usr/bin/env bash
# Migracja ~/NixOS-config do nowej struktury (hosts/ modules/ wallpapers/ docs/).
# Uruchom z KATALOGU GŁÓWNEGO repo:   bash migrate.sh
# Pliki są przenoszone przez `git mv` (historia zostaje), nic nie jest kasowane.
set -euo pipefail

[ -f flake.nix ] && [ -d core ] && [ -d assets ] \
  || { echo "Uruchom w głównym katalogu repo (potrzebne: flake.nix, core/, assets/)."; exit 1; }
[ ! -d modules ] \
  || { echo "modules/ już istnieje - wygląda na to, że migracja już była uruchomiona."; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null

# Zmiany w tych dwóch plikach nam nie przeszkadzają (są generowane i trafią do .gitignore)
if ! git diff --quiet HEAD -- . ':!NixOS-config.txt' ':!nixos_konfiguracja_dla_ai.txt' \
   || [ -n "$(git ls-files --others --exclude-standard | grep -v -x 'migrate.sh')" ]; then
  echo "Masz niezatwierdzone zmiany lub nowe pliki. Zrób najpierw commit (git add -A && git commit), potem uruchom ponownie."
  exit 1
fi
# czy sam skrypt jest śledzony przez git? (jeśli nie, nie dołączamy go na końcu do zmian)
SELF_TRACKED=0; git ls-files --error-unmatch migrate.sh >/dev/null 2>&1 && SELF_TRACKED=1
BACKUP_TAG="pre-restructure-$(date +%Y%m%d-%H%M%S)"
git tag "$BACKUP_TAG"
echo ">> Punkt powrotu: git tag $BACKUP_TAG   (cofnięcie: git reset --hard $BACKUP_TAG)"

N=modules/nixos
H=modules/home
D=$N/desktop

# mv_f ŹRÓDŁO CEL  - tworzy katalog docelowy, używa git mv (a gdy plik nie jest w gicie - zwykłego mv)
mv_f() {
  if [ ! -e "$1" ]; then echo "   (brak: $1 - pomijam)"; return 0; fi
  mkdir -p "$(dirname "$2")"
  git mv "$1" "$2" 2>/dev/null || mv "$1" "$2"
}

# ------------------------------------------------------------------
echo ">> [1/6] shell.nix - wycinam bash i aliasy z home/default.nix (zanim zostanie nadpisany)"
mkdir -p $H
{
  printf '{ ... }:\n\n{\n  programs.bash.enable = true;\n\n'
  sed -n '/home.shellAliases/,/^  };/p' home/default.nix
  printf '}\n'
} > $H/shell.nix

# ------------------------------------------------------------------
echo ">> [2/6] Przenoszenie plików"

# --- NixOS: common ---
mv_f core/users.nix            $N/common/user.nix
mv_f core/locale.nix           $N/common/locale.nix

# --- NixOS: desktop ---
mv_f core/audio.nix            $D/audio.nix
mv_f core/fonts.nix            $D/fonts.nix
mv_f core/keyboard.nix         $D/keyboard.nix
mv_f core/network.nix          $D/network.nix        # zostanie nadpisany niżej (bez tailscale i hostName)
mv_f core/packages.nix         $D/packages.nix
mv_f core/system.nix           $D/system.nix         # zostanie nadpisany niżej (bez nix.settings)
mv_f core/thunar.nix           $D/thunar.nix
mv_f core/wayland.nix          $D/wayland.nix
mv_f core/plymouth.nix         $D/plymouth.nix
mv_f assets/plymouth-logo.png  $D/plymouth-logo.png
mv_f core/theme.nix            $D/stylix.nix
mv_f core/grub.nix             $D/grub/default.nix
mv_f core/sddm.nix             $D/sddm/default.nix

for f in assets/Grub-Theme/*; do mv_f "$f" "$D/grub/$(basename "$f")"; done

mv_f assets/SDDM-Theme/Main.qml        $D/sddm/Main.qml
mv_f assets/SDDM-Theme/metadata.desktop $D/sddm/metadata.desktop
mv_f assets/SDDM-Theme/theme.conf      $D/sddm/theme.conf
mv_f assets/SDDM-Theme/components      $D/sddm/components
mv_f assets/SDDM-Theme/assets          $D/sddm/assets

# --- NixOS: services ---
mv_f core/ollama.nix                   $N/services/ollama.nix
mv_f hosts/server/caddy.nix            $N/services/caddy.nix
mv_f hosts/server/media.nix            $N/services/media.nix
mv_f hosts/server/qbit-cleanup.nix     $N/services/qbit-cleanup.nix

# --- hosts ---
mv_f core/power.nix                    hosts/laptop/power.nix

# --- Home Manager ---
mv_f home/default.nix                  $H/default.nix       # zostanie nadpisany niżej
mv_f home/packages.nix                 $H/packages.nix
mv_f home/theme.nix                    $H/theme.nix
mv_f home/desktop_entries.nix          $H/desktop-entries.nix
mv_f home/ghostty.nix                  $H/ghostty.nix
mv_f home/zed.nix                      $H/zed.nix
mv_f home/lock.nix                     $H/lock.nix

mv_f home/hyprland.nix                 $H/hyprland/default.nix
mv_f assets/Hyprland-Config/hyprland.lua $H/hyprland/hyprland.lua

mv_f home/waybar.nix                   $H/waybar/default.nix
mv_f assets/Waybar-Config/config.jsonc $H/waybar/config.jsonc
mv_f assets/Waybar-Config/style.css    $H/waybar/style.css

mv_f home/rofi.nix                     $H/rofi/default.nix
mv_f assets/Rofi-Theme/files           $H/rofi/files
mv_f assets/Rofi-Theme/fonts           $H/rofi/fonts

mv_f home/walker.nix                   $H/walker/default.nix
mv_f assets/Walker/config.toml         $H/walker/config.toml
mv_f assets/Walker/custom.css          $H/walker/custom.css

mv_f assets/SwayOSD/config.toml        $H/swayosd/config.toml
mv_f assets/SwayOSD/style.css          $H/swayosd/style.css

mv_f home/scripts.nix                  $H/scripts/default.nix
for f in assets/Scripts/*; do mv_f "$f" "$H/scripts/$(basename "$f")"; done

# --- wallpapers i docs ---
mv_f assets/Wallpapers                 wallpapers
mv_f assets/stylix.txt                 docs/stylix.txt
mv_f assets/WALLPAPER_HEAVEN.txt       docs/wallpaper-heaven.txt

# --- nieużywane pozostałości (nic ich nie importuje; hyprpaper.conf ma stare, bezwzględne ścieżki) ---
mv_f assets/Hyprland-Config/hyprland.conf   docs/legacy/hyprland.conf
mv_f assets/Hyprland-Config/hyprpaper.conf  docs/legacy/hyprpaper.conf

# core/default.nix jest zastąpiony przez desktop/default.nix + common/default.nix
git rm -q core/default.nix

# ------------------------------------------------------------------
echo ">> [3/6] Poprawki ścieżek w plikach, które tylko się przeniosły (sed)"
sed -i 's|\.\./assets/plymouth-logo\.png|./plymouth-logo.png|'                 $D/plymouth.nix
sed -i 's|\.\./assets/Wallpapers/|../../../wallpapers/|'                        $D/stylix.nix
sed -i 's|\.\./assets/Wallpapers/|../../wallpapers/|'                           $H/lock.nix
sed -i 's|\.\./assets/Hyprland-Config/hyprland\.lua|./hyprland.lua|'            $H/hyprland/default.nix
sed -i 's|\.\./assets/Rofi-Theme/|./|'                                          $H/rofi/default.nix
sed -i 's|\.\./assets/Walker/|./|'                                              $H/walker/default.nix
sed -i 's|(hosts/server/network\.nix)|(modules/nixos/common/tailscale.nix)|'    $N/services/caddy.nix

# ------------------------------------------------------------------
echo ">> [4/6] Nowe i przepisane pliki .nix"

# ===== flake.nix =====
cat > flake.nix <<'EOF'
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
EOF

# ===== hosts/laptop/default.nix =====
cat > hosts/laptop/default.nix <<'EOF'
{ inputs, ... }:

{
  imports = [
    inputs.stylix.nixosModules.stylix
    inputs.home-manager.nixosModules.home-manager

    ./hardware.nix
    ./power.nix

    ../../modules/nixos/common
    ../../modules/nixos/desktop
    ../../modules/nixos/services/ollama.nix
  ];

  networking.hostName = "DCNIX";
  boot.kernelModules = [ "pkcs8_key_parser" ]; # ????????

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    # Główny plik konfiguracji Home Managera
    users.damian2120 = import ../../modules/home/default.nix;
  };

  system.stateVersion = "25.11";
}
EOF

# ===== hosts/server/default.nix =====
cat > hosts/server/default.nix <<'EOF'
{ config, pkgs, ... }:

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
  ];

  networking.hostName = "DCSRW";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

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
EOF

# ===== hosts/server/network.nix =====
cat > hosts/server/network.nix <<'EOF'
{ config, pkgs, ... }:

{
  # Tailscale (enable, port UDP, tailscale0 jako zaufany) jest w modules/nixos/common/tailscale.nix.
  # Tutaj tylko to, co dotyczy serwera: kontenery Podmana też są zaufane.
  networking.firewall.trustedInterfaces = [ "podman0" ];

  # ADGUARD HOME - prywatny DNS i bloker reklam
  services.adguardhome = {
    enable = true;
    openFirewall = true; # Automatycznie otwiera porty: 53 (DNS) i 3000 (Panel WWW)
  };
}
EOF

# ===== modules/nixos/common =====
cat > $N/common/default.nix <<'EOF'
{
  imports = [
    ./nix.nix
    ./user.nix
    ./tailscale.nix
    ./locale.nix
  ];
}
EOF

cat > $N/common/nix.nix <<'EOF'
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
EOF

cat > $N/common/tailscale.nix <<'EOF'
{ config, ... }:

{
  services.tailscale.enable = true;

  networking.firewall = {
    # Port Tailscale w UDP ułatwia bezpośrednie, szybkie połączenia
    allowedUDPPorts = [ config.services.tailscale.port ];
    # Ufaj urządzeniom z sieci Tailscale
    trustedInterfaces = [ "tailscale0" ];
  };
}
EOF

# ===== modules/nixos/desktop =====
cat > $D/default.nix <<'EOF'
{
  imports = [
    ./audio.nix
    ./fonts.nix
    ./keyboard.nix
    ./network.nix
    ./packages.nix
    ./system.nix
    ./thunar.nix
    ./wayland.nix
    ./stylix.nix
    ./grub
    ./sddm
    # ./plymouth.nix   # nieaktywny (celowo niezaimportowany)
  ];
}
EOF

cat > $D/network.nix <<'EOF'
{ config, pkgs, ... }:

{
  networking.wireless.iwd.enable = true;
  services.resolved.enable = true;

  # NetworkManager (używany w Waybarze) ma używać iwd jako silnika do WiFi:
  networking.networkmanager.wifi.backend = "iwd";

  # Porty LocalSend
  networking.firewall = {
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };
}
EOF

cat > $D/system.nix <<'EOF'
{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.desktopManager.xterm.enable = false;
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;
}
EOF

# fileset: do motywu trafia wszystko z katalogu OPRÓCZ default.nix
cat > $D/grub/default.nix <<'EOF'
{ lib, pkgs, ... }:

let
  Grub-Theme = pkgs.stdenv.mkDerivation {
    name = "Grub-Theme";
    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.difference ./. ./default.nix;
    };

    installPhase = ''
      # Tworzymy główny folder w Nix Store
      mkdir -p $out
      # Kopiujemy do niego całą zawartość motywu (tam, gdzie jest theme.txt)
      cp -r ./* $out/
    '';
  };
in
{
  # Podpinamy motyw do ustawień bootloadera
  boot.loader.grub = {
    enable = true;
    theme = "${Grub-Theme}";
    device = "nodev";
    efiSupport = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
}
EOF

cat > $D/sddm/default.nix <<'EOF'
{ lib, pkgs, ... }:

let
  # Lokalny motyw (cały katalog oprócz default.nix)
  SDDM-Theme = pkgs.stdenv.mkDerivation {
    name = "SDDM-Theme";
    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.difference ./. ./default.nix;
    };

    installPhase = ''
      mkdir -p $out/share/sddm/themes/SDDM-Theme
      cp -r ./* $out/share/sddm/themes/SDDM-Theme/
    '';
  };
in
{
  # Dodajemy motyw do pakietów systemowych
  environment.systemPackages = [ SDDM-Theme ];

  services.displayManager.sddm = {
    enable = true;
    theme = "SDDM-Theme";

    # WYŁĄCZAMY Waylanda dla samego ekranu logowania.
    # To zapobiega crashom i zrzucaniu do TTY po wylogowaniu z Hyprlanda.
    wayland.enable = false;

    # Biblioteki Qt niezbędne do poprawnego renderowania motywu QML
    extraPackages = with pkgs.kdePackages; [
      qtsvg        # Obsługa ikon i grafik SVG w motywie
      qt5compat    # Kompatybilność wsteczna dla elementów QML
    ];
  };
}
EOF

# ===== modules/home =====
cat > $H/default.nix <<'EOF'
{ config, pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./packages.nix
    ./theme.nix
    ./desktop-entries.nix
    ./ghostty.nix
    ./zed.nix
    ./lock.nix
    ./hyprland
    ./waybar
    ./rofi
    ./walker
    ./swayosd
    ./scripts
  ];

  fonts.fontconfig.enable = true;

  home.username = "damian2120";
  home.homeDirectory = "/home/damian2120";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
EOF

cat > $H/scripts/default.nix <<'EOF'
{ lib, pkgs, ... }:

let
  scripts = [
    "brightness.sh"
    "mic.sh"
    "launcher.sh"
    "powermenu.sh"
    "launch-walker.sh"
    "eduroam.sh"
    "codebase.sh"
  ];
in
{
  home.packages = with pkgs; [ iw wpa_supplicant dhcpcd ];

  # Każdy skrypt z tego katalogu ląduje w ~/.config/Scripts/ jako wykonywalny
  home.file = lib.listToAttrs (map (name: {
    name = ".config/Scripts/${name}";
    value = {
      source = ./. + "/${name}";
      executable = true;
    };
  }) scripts);
}
EOF

cat > $H/swayosd/default.nix <<'EOF'
{ ... }:

{
  # (usługa swayosd jest włączona w ../packages.nix)
  # KLUCZOWE: config.toml znosi limit 5% i włącza tekst procentów
  home.file.".config/swayosd/config.toml".source = ./config.toml;
  home.file.".config/swayosd/style.css".source = ./style.css;
}
EOF

cat > $H/waybar/default.nix <<'EOF'
{ config, pkgs, ... }:

{
  xdg.configFile."waybar/config.jsonc".source = ./config.jsonc;
  xdg.configFile."waybar/style.css".source = ./style.css;

  home.packages = with pkgs; [
    waybar
    playerctl
    impala
    btop
    bluetui
    wiremix
  ];
}
EOF

# codebase.sh: nowe nazwy katalogów do pominięcia w eksporcie
cat > $H/scripts/codebase.sh <<'EOF'
#!/usr/bin/env bash

# Zawsze ustawiamy ścieżkę do Twojej konfiguracji w folderze domowym
TARGET_DIR="$HOME/NixOS-config"
OUTPUT="$TARGET_DIR/NixOS-config.txt"

# Przechodzimy do folderu konfiguracji
cd "$TARGET_DIR" || exit 1

# Wyczyść plik wynikowy, jeśli istnieje
> "$OUTPUT"

echo "========================================" >> "$OUTPUT"
echo "STRUKTURA KATALOGÓW" >> "$OUTPUT"
echo "========================================" >> "$OUTPUT"

# Zapisz strukturę drzewa z wykluczeniem zbędnych elementów
tree -I "wallpapers|fonts|assets|components|*.png|*.jpg|.git|flake.lock|NixOS-config.txt|nixos_konfiguracja_dla_ai.txt|codebase.sh|zbierz.sh" >> "$OUTPUT"
echo -e "\n\n" >> "$OUTPUT"

# Wyszukaj wszystkie pliki z pominięciem konkretnych ścieżek.
# Z motywów GRUB i SDDM zostaje tylko default.nix.
find . -type f \
    -not -path "*/.git/*" \
    -not -path "*/wallpapers/*" \
    -not -path "*/fonts/*" \
    -not \( \( -path "*/desktop/grub/*" -o -path "*/desktop/sddm/*" \) -not -name "default.nix" \) \
    -not -name "NixOS-config.txt" \
    -not -name "nixos_konfiguracja_dla_ai.txt" \
    -not -name "zbierz.sh" \
    -not -name "codebase.sh" \
    -not -name "flake.lock" | sort | while read -r filepath; do

    # Sprawdzenie MIME: upewnia się, że plik to faktycznie tekst
    if file -b "$filepath" | grep -iq "text\|empty"; then
        echo "========================================" >> "$OUTPUT"
        echo "PLIK: ${filepath#./}" >> "$OUTPUT"
        echo "========================================" >> "$OUTPUT"
        cat "$filepath" >> "$OUTPUT"
        echo -e "\n" >> "$OUTPUT"
    fi
done

echo "Gotowe! Wszystko zostało zebrane w pliku $OUTPUT"
EOF
chmod +x $H/scripts/codebase.sh

# ------------------------------------------------------------------
echo ">> [5/6] .gitignore"
touch .gitignore
for p in NixOS-config.txt nixos_konfiguracja_dla_ai.txt; do
  grep -qxF "$p" .gitignore || echo "$p" >> .gitignore
done
git rm -q --cached --ignore-unmatch NixOS-config.txt nixos_konfiguracja_dla_ai.txt >/dev/null

# ------------------------------------------------------------------
echo ">> [6/6] Sprzątanie pustych katalogów i dodanie zmian do gita (flake widzi tylko pliki znane gitowi)"
find assets core home -depth -type d -empty -delete 2>/dev/null || true
git add -A
[ "$SELF_TRACKED" = 1 ] || git reset -q -- migrate.sh 2>/dev/null || true

echo
echo "Gotowe."
if [ -d assets ] || [ -d core ] || [ -d home ]; then
  echo "Zostały pliki, których nie ma w nowym schemacie (sprawdź i usuń ręcznie, jeśli zbędne):"
  find assets core home -type f 2>/dev/null | sed 's/^/   /'
fi
echo
if command -v nix >/dev/null 2>&1; then
  echo ">> Sprawdzam, czy obie konfiguracje się ewaluują (bez budowania)..."
  for h in DCNIX DCSRW; do
    if nix eval --raw ".#nixosConfigurations.$h.config.system.build.toplevel.drvPath" >/dev/null; then
      echo "   $h: OK"
    else
      echo "   $h: BŁĄD (cofnij: git reset --hard $BACKUP_TAG)"
    fi
  done
fi
echo "Dalej:  nix flake check   oraz   nh os test   (laptop),  nixos-rebuild build --flake .#DCSRW  (serwer)"
