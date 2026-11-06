{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    loadModels = [
      "qwen2.5-coder:1.5b"
      "qwen2.5-coder:7b"
    ];
    # Usługa włączy się automatycznie ze startem systemu
  };
}
