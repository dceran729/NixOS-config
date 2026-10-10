{ config, pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor-fhs;

    userSettings = {
      # Konfiguracja Asystenta bocznego (Czat)
      assistant = {
        enabled = true;
        version = "2";
        default_model = {
          provider = "zed.dev";
          model = "claude-3-5-sonnet-latest";
        };
      };

      # Konfiguracja podpowiadania kodu w locie (Inline)
      features = {
        # Używamy darmowego wbudowanego Zed AI do podpowiedzi
        inline_completion_provider = "zed";
      };
    };
  };
}
