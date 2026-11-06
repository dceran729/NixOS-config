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
