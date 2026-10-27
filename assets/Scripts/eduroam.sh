#!/usr/bin/env bash
# Przełącznik eduroam: zatrzymuje iwd i uruchamia wpa_supplicant (eduroam.service)

notify() { command -v notify-send >/dev/null && notify-send "eduroam" "$1"; echo "$1"; }
active() { systemctl is-active --quiet eduroam.service; }

case "${1:-toggle}" in
  on)  systemctl start eduroam.service && notify "eduroam włączone (iwd wyłączony)" || notify "Nie udało się włączyć eduroam" ;;
  off) systemctl stop eduroam.service && notify "eduroam wyłączone, wraca iwd" || notify "Nie udało się wyłączyć eduroam" ;;
  toggle) if active; then "$0" off; else "$0" on; fi ;;
  status) if active; then echo "eduroam: włączone"; else echo "eduroam: wyłączone"; fi ;;
  *) echo "użycie: $0 on|off|toggle|status"; exit 1 ;;
esac
