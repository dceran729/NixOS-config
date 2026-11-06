{ config, lib, pkgs, ... }:

let
  c = config.lib.stylix.colors;          # kolory z Twojego schematu onedark
  font = "JetBrainsMono Nerd Font";
  hyprlock = lib.getExe config.programs.hyprlock.package;

  # Hyprland 0.57+: hyprctl dispatch przyjmuje wyrażenie Lua (stare "dpms off" już nie działa)
  dpmsOff = "hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'";
  dpmsOn  = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
in
{
  # Stylix ma własny target hyprlocka (kolory + tapeta) -
  # wyłączamy go, żeby nie kolidował z poniższym wyglądem.
  stylix.targets.hyprlock.enable = false;

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;     # pusty Enter nie liczy się jako błędne hasło
      };

      animations = {
        enabled = true;
        bezier = "easeOut, 0.2, 0.8, 0.2, 1.0";
        animation = [
          "fade, 1, 3, easeOut"
          "inputFieldDots, 1, 2, easeOut"
        ];
      };

      background = [{
        monitor = "";
        # plik z obrazem, nie "screenshot" (screencopy wymagałby uprawnień
        # przy ecosystem:enforce_permissions = true)
        path = "${../../wallpapers/a_planet_in_space_with_clouds.jpg}";
        blur_passes = 3;
        blur_size = 6;
        brightness = 0.6;
        noise = 0.02;
      }];

      label = [
        {   # godzina
          monitor = "";
          text = "$TIME";
          font_size = 96;
          font_family = font;
          color = "rgb(${c.base05})";
          position = "0, 180";
          halign = "center";
          valign = "center";
        }
        {   # data (odświeżana co minutę)
          monitor = "";
          text = ''cmd[update:60000] date +"%A, %-d %B"'';
          font_size = 22;
          font_family = font;
          color = "rgb(${c.base04})";
          position = "0, 90";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [{
        monitor = "";
        size = "340, 58";
        outline_thickness = 2;
        rounding = 14;
        dots_size = 0.25;
        dots_spacing = 0.35;
        dots_center = true;
        outer_color = "rgb(${c.base0D})";
        inner_color = "rgba(${c.base00}cc)";
        font_color = "rgb(${c.base05})";
        check_color = "rgb(${c.base0A})";
        fail_color = "rgb(${c.base08})";
        fade_on_empty = false;
        placeholder_text = ''<span foreground="##${c.base04}">Hasło...</span>'';
        fail_text = "<i>$FAIL ($ATTEMPTS)</i>";
        position = "0, -60";
        halign = "center";
        valign = "center";
      }];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${hyprlock}";  # nie startuj dwóch instancji
        before_sleep_cmd = "loginctl lock-session";  # blokada przed uśpieniem/pokrywą
        after_sleep_cmd = dpmsOn;
      };

      listener = [
        {
          # Po 5 minutach bezczynności: zablokuj i wygaś ekran.
          # sleep 1 daje hyprlockowi chwilę na narysowanie się przed wygaszeniem,
          # dzięki czemu po wybudzeniu od razu widzisz ekran blokady.
          timeout = 300;
          on-timeout = "loginctl lock-session && sleep 1 && ${dpmsOff}";
          on-resume = dpmsOn;
        }

        # Opcjonalnie: uśpienie po 20 minutach (odkomentuj, jeśli chcesz)
        # {
        #   timeout = 1200;
        #   on-timeout = "systemctl suspend-then-hibernate";
        # }
      ];
    };
  };
}
