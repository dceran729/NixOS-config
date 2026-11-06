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
