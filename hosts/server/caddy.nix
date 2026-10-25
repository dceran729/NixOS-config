{ config, lib, pkgs, ... }:

let
  # Nazwa serwera w Tailscale, wyciągnięta z DOMAIN Vaultwardena (media.nix),
  # żeby adres był zapisany tylko w jednym miejscu.
  vaultHost = lib.removePrefix "https://" config.services.vaultwarden.config.DOMAIN;
in
{
  # Pozwala Caddy pobrać od Tailscale prawdziwy certyfikat (Let's Encrypt)
  # dla nazwy *.ts.net. Dzięki temu nie trzeba nigdzie instalować własnego
  # certyfikatu ani konfigurować DNS. Wymaga włączonego "HTTPS Certificates"
  # w panelu Tailscale (zakładka DNS).
  services.tailscale.permitCertUid = "caddy";

  # Caddy obsługuje tylko Vaultwardena. Reszta aplikacji jest dostępna
  # bezpośrednio pod IP:port.
  services.caddy = {
    enable = true;
    virtualHosts.${vaultHost}.extraConfig = ''
      reverse_proxy 127.0.0.1:8222
    '';
  };

  # Porty 80/443 nie są otwierane w zaporze: ruch przychodzi przez interfejs
  # tailscale0, który jest zaufany (hosts/server/network.nix).
}
