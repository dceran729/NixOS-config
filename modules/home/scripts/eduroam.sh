#!/usr/bin/env bash
# Przełącznik eduroam (PUT, EAP-TLS przez wpa_supplicant).
# Jeśli eduroam jest wyłączone, włącza je (iwd zostaje zatrzymany).
# Jeśli jest włączone, wyłącza je i przywraca iwd.

D=/var/lib/eduroam
IFACE=eduroam0
PIDFILE=/run/eduroam-wpa.pid

# sudo nie widzi programów z profilu użytkownika, więc przekazujemy ich ścieżki
if [ "$EUID" -ne 0 ]; then
  exec sudo env IW="$(command -v iw)" WPA="$(command -v wpa_supplicant)" \
    DHCP="$(command -v dhcpcd)" "$0" "$@"
fi

for v in IW WPA DHCP; do
  if [ ! -x "${!v}" ]; then
    echo "Brak programu ($v). Czy zrobiłeś rebuild po dodaniu skryptu?"
    exit 1
  fi
done

active() { [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; }

off() {
  if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
  fi
  "$DHCP" -k "$IFACE" 2>/dev/null
  ip link delete "$IFACE" 2>/dev/null
  rm -f /run/eduroam-wpa.conf
  echo "Przywracam iwd..."
  systemctl start iwd
  for _ in $(seq 1 30); do
    ip link show wlan0 >/dev/null 2>&1 && break
    sleep 1
  done
  echo "Gotowe: eduroam wyłączone. NetworkManager połączy się sam, impala działa."
}

on() {
  if [ ! -f "$D/eduroam-client.pem" ] || [ ! -f "$D/eduroam-key.pem" ]; then
    echo "Brak certyfikatów w $D"
    exit 1
  fi

  echo "Zatrzymuję iwd..."
  systemctl stop iwd
  sleep 2

  PHY=$("$IW" phy | awk '/^Wiphy/{print $2; exit}')
  ip link delete "$IFACE" 2>/dev/null
  if ! "$IW" phy "$PHY" interface add "$IFACE" type managed; then
    echo "Nie udało się utworzyć interfejsu $IFACE"
    off
    exit 1
  fi
  nmcli device set "$IFACE" managed no 2>/dev/null
  ip link set "$IFACE" up

  cat > /run/eduroam-wpa.conf <<EOF
network={
  ssid="eduroam"
  key_mgmt=WPA-EAP
  eap=TLS
  identity="damian.ceran@student.put.poznan.pl"
  client_cert="$D/eduroam-client.pem"
  private_key="$D/eduroam-key.pem"
}
EOF
  chmod 600 /run/eduroam-wpa.conf

  echo "Łączenie z eduroam..."
  "$WPA" -B -i "$IFACE" -c /run/eduroam-wpa.conf -P "$PIDFILE" -f /run/eduroam-wpa.log

  for _ in $(seq 1 30); do
    [ "$(cat /sys/class/net/$IFACE/carrier 2>/dev/null)" = 1 ] && break
    sleep 1
  done

  if [ "$(cat /sys/class/net/$IFACE/carrier 2>/dev/null)" != 1 ]; then
    echo "Nie udało się uwierzytelnić. Ostatnie linie logu:"
    tail -n 15 /run/eduroam-wpa.log 2>/dev/null
    off
    exit 1
  fi

  "$DHCP" -q "$IFACE"
  sleep 2
  ip -br addr show "$IFACE"
  echo "Gotowe: eduroam włączone (iwd wyłączony). Uruchom skrypt ponownie, żeby wyłączyć."
}

if active; then off; else on; fi
