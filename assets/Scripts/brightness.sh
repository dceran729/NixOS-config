#!/usr/bin/env bash

ACTION=$1
MAX=$(brightnessctl max)
CURRENT_RAW=$(brightnessctl get)
CURRENT=$(( CURRENT_RAW * 100 / MAX ))

if [[ "$ACTION" == "up" ]]; then
    if (( CURRENT < 5 )); then
        TARGET=$(( CURRENT + 1 ))
    else
        TARGET=$(( (CURRENT / 5) * 5 + 5 ))
    fi
    (( TARGET > 100 )) && TARGET=100

elif [[ "$ACTION" == "down" ]]; then
    if (( CURRENT <= 5 )); then
        TARGET=$(( CURRENT - 1 ))
    else
        TARGET=$(( (CURRENT / 5) * 5 ))
        if (( TARGET == CURRENT )); then
            TARGET=$(( CURRENT - 5 ))
        fi
    fi
    (( TARGET < 1 )) && TARGET=1
else
    exit 1
fi

# Ustawiamy fizyczną jasność

swayosd-client --brightness "$TARGET"
