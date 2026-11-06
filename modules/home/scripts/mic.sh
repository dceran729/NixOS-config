#!/usr/bin/env bash

# 1. Fizyczna zmiana stanu wyciszenia w WirePlumber / PipeWire
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Dajemy systemowi ułamek sekundy na przetworzenie zmiany
# sleep 0.1

# 2. Odczyt aktualnego stanu z wpctl
STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)

if echo "$STATUS" | grep -qi "MUTED"; then
    # MIKROFON WYCISZONY
    swayosd-client --custom-progress 0 --custom-icon "microphone-sensitivity-muted-symbolic"
else
    # MIKROFON AKTYWNY
    VOL=$(echo "$STATUS" | LC_NUMERIC=C awk '{print int($2 * 100)}')
    swayosd-client --custom-progress 100 --custom-icon "microphone-sensitivity-high-symbolic"
fi
