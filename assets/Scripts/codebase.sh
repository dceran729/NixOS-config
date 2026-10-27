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
tree -I "Grub-Theme|SDDM-Theme|Wallpapers|fonts|.git|flake.lock|NixOS-config.txt|codebase.sh|zbierz.sh" >> "$OUTPUT"
echo -e "\n\n" >> "$OUTPUT"

# Wyszukaj wszystkie pliki z pominięciem konkretnych ścieżek
find . -type f \
    -not -path "*/Grub-Theme/*" \
    -not -path "*/SDDM-Theme/*" \
    -not -path "*/Wallpapers/*" \
    -not -path "*/fonts/*" \
    -not -path "*/.git/*" \
    -not -name "NixOS-config.txt" \
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
