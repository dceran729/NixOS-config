{ config, pkgs, ... }:

{
  # 1. Główny program i jego wtyczki
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  # 2. Usługi wymagane przez Thunara (Kosz, miniatury, montowanie)
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true;

  # 3. Włączenie systemu uprawnień (Polkit)
  security.polkit.enable = true;

  # 4. Reguła pozwalająca Twojemu użytkownikowi montować dyski bez podawania hasła
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.udisks2.filesystem-mount" ||
             action.id == "org.freedesktop.udisks2.filesystem-mount-system") &&
            subject.isInGroup("wheel")) {
            return polkit.Result.YES;
        }
    });
  '';
}
