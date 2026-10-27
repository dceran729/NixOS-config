#!/usr/bin/env bash

OUTPUT="NixOS-config.txt"

# Wyczyść plik wynikowy, jeśli istnieje
> "$OUTPUT"

echo "========================================" >> "$OUTPUT"
echo "STRUKTURA KATALOGÓW" >> "$OUTPUT"
echo "========================================" >> "$OUTPUT"

# Zapisz strukturę drzewa, ignorując wykluczone foldery
# (dodano fonts oraz flake.lock, aby nie zaśmiecać widoku drzewa)
tree -I "Grub-Theme|SDDM-Theme|Wallpapers|fonts|.git|flake.lock|$OUTPUT|zbierz.sh" >> "$OUTPUT"
echo -e "\n\n" >> "$OUTPUT"

# Wyszukaj wszystkie pliki z pominięciem konkretnych ścieżek
find . -type f \
    -not -path "*/Grub-Theme/*" \
    -not -path "*/SDDM-Theme/*" \
    -not -path "*/Wallpapers/*" \
    -not -path "*/fonts/*" \
    -not -path "*/.git/*" \
    -not -name "$OUTPUT" \
    -not -name "zbierz.sh" \
    -not -name "flake.lock" | sort | while read -r filepath; do

    # Sprawdzenie MIME: upewnia się, że plik to faktycznie tekst (omija ew. zagubione PNG/JPG/TTF)
    if file -b "$filepath" | grep -iq "text\|empty"; then
        echo "========================================" >> "$OUTPUT"
        echo "PLIK: ${filepath#./}" >> "$OUTPUT"
        echo "========================================" >> "$OUTPUT"
        cat "$filepath" >> "$OUTPUT"
        echo -e "\n" >> "$OUTPUT"
    fi
done

echo "Gotowe! Wszystko zostało zebrane w pliku $OUTPUT"
