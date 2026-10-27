{ config, pkgs, ... }:

let
  wpaConf = pkgs.writeText "eduroam-wpa.conf" ''
    network={
      ssid="eduroam"
      key_mgmt=WPA-EAP
      eap=TLS
      identity="damian.ceran@student.put.poznan.pl"
      client_cert="/var/lib/eduroam/eduroam-client.pem"
      private_key="/var/lib/eduroam/eduroam-key.pem"
    }
  '';

  pre = pkgs.writeShellScript "eduroam-pre" ''
    sleep 1
    ${pkgs.iproute2}/bin/ip link delete eduroam0 2>/dev/null || true
    phy=$(${pkgs.iw}/bin/iw phy | ${pkgs.gawk}/bin/awk '/^Wiphy/{print $2; exit}')
    ${pkgs.iw}/bin/iw phy "$phy" interface add eduroam0 type managed
    ${pkgs.iproute2}/bin/ip link set eduroam0 up
  '';

  post = pkgs.writeShellScript "eduroam-post" ''
    ${pkgs.iproute2}/bin/ip link delete eduroam0 2>/dev/null || true
    ${pkgs.systemd}/bin/systemctl start --no-block iwd.service || true
  '';
in
{
  # eduroam (PUT) wymaga wpa_supplicant, bo iwd nie radzi sobie z negocjacją EAP serwera
  systemd.services.eduroam = {
    description = "eduroam przez wpa_supplicant (zamiast iwd)";
    conflicts = [ "iwd.service" ];
    after = [ "iwd.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pre}";
      ExecStart = "${pkgs.wpa_supplicant}/bin/wpa_supplicant -i eduroam0 -c ${wpaConf}";
      ExecStopPost = "${post}";
    };
  };

  # Adres IP dla interfejsu eduroam0 (tylko on, reszta zostaje po stronie NetworkManagera)
  systemd.network.enable = true;
  systemd.network.wait-online.enable = false;
  systemd.network.networks."40-eduroam" = {
    matchConfig.Name = "eduroam0";
    networkConfig.DHCP = "yes";
    linkConfig.RequiredForOnline = "no";
  };
  networking.networkmanager.unmanaged = [ "interface-name:eduroam0" ];

  # Katalog na certyfikat i klucz
  systemd.tmpfiles.rules = [ "d /var/lib/eduroam 0700 root root -" ];

  # Użytkownik z grupy wheel może włączać/wyłączać usługę bez sudo
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "eduroam.service" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';
}
