{ ... }:

{
  # (usługa swayosd jest włączona w ../packages.nix)
  # KLUCZOWE: config.toml znosi limit 5% i włącza tekst procentów
  home.file.".config/swayosd/config.toml".source = ./config.toml;
  home.file.".config/swayosd/style.css".source = ./style.css;
}
