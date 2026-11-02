--------------------------------------------------------------------------------
-- KONFIGURACJA HYPRLAND (Lua) - Hyprland 0.57+
-- Przetłumaczone z hyprland.conf (hyprlang). Zmiany wykraczające poza samo
-- tłumaczenie są oznaczone komentarzem "NOWE".
--------------------------------------------------------------------------------

---------------------
-- ZMIENNE (dawne $) --
---------------------
local mainMod     = "SUPER"
local terminal    = "ghostty"
local fileManager = "thunar"
local menu        = "~/.config/Scripts/launcher.sh"
local powermenu   = "~/.config/Scripts/powermenu.sh"
local browser     = "firefox"

---------------
-- MONITORY --
---------------
hl.monitor({ output = "eDP-1",    mode = "preferred", position = "auto", scale = 1.2 })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1.2 })

---------------
-- AUTOSTART --
---------------
-- exec-once = ... -> zdarzenie hyprland.start (uruchamia się tylko przy starcie)
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar & lxqt-policykit-agent")
end)

---------------------------
-- ZMIENNE ŚRODOWISKOWE --
---------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
-- WYGLĄD I ZACHOWANIE --
-----------------------
hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 3,

        -- 0xff00c6fc (AARRGGBB) -> rgba(RRGGBBAA)
        col = {
            active_border = "rgba(00c6fcff)",
            -- inactive_border = "rgba(000000ff)",
        },

        resize_on_border = true,
        extend_border_grab_area = 20,
        hover_icon_on_border = false,

        layout = "scrolling",

        allow_tearing = false,

        snap = {
            enabled = false,
        },
    },

    decoration = {
        rounding = 0,

        active_opacity = 1.0,
        inactive_opacity = 1.0,

        dim_inactive = true,
        dim_around = 0.1,
        dim_special = 0.2,
        dim_strength = 0.1,

        shadow = {
            enabled = false,
        },

        blur = {
            enabled = false,
        },
    },

    animations = {
        enabled = true,
    },
})

----------------
-- ANIMACJE --
----------------
-- bezier = ... -> hl.curve(), animation = ... -> hl.animation()
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1.0 }, { 0.32, 1.0 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1.0 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1.0 } } })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle",   enabled = false })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })

-- Obszary robocze: ruch góra-dół
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 2.5,  bezier = "easeOutQuint", style = "slidevert" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "slidevert" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "slidevert" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

--------------------
-- WEJŚCIE I GESTY --
--------------------
hl.config({
    input = {
        kb_layout = "pl",
        follow_mouse = 1,
        sensitivity = 0,
        natural_scroll = true,

        touchpad = {
            natural_scroll = true,
            -- drag_lock = false  <- pominięte: domyślnie wyłączone, a typ opcji
            --                       zmienił się w nowszych wersjach (bool -> int)
            middle_button_emulation = true,
        },
    },

    gestures = {
        workspace_swipe_distance = 300,
        workspace_swipe_direction_lock = true,
        workspace_swipe_forever = false,
        workspace_swipe_touch = false,
        workspace_swipe_touch_invert = true,
        workspace_swipe_use_r = true,
    },
})

-- Zmiana obszarów roboczych ruchem 3 palców pionowo
hl.gesture({ fingers = 3, direction = "vertical", action = "workspace" })

-- Specyficzna czułość dla myszy
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------------------------
-- UKŁADY I USTAWIENIA SYSTEMOWE --
---------------------------------------
hl.config({
    dwindle = {
        preserve_split = true,
        force_split = 2,
    },

    master = {
        new_status = "slave",
        allow_small_split = false,
        mfact = 0.5,
        new_on_active = "after",
        new_on_top = false,
        special_scale_factor = 1.0,
    },

    scrolling = {
        follow_min_visible = 1.0,
        focus_fit_method = 1,   -- NOWE: jawnie (1 = dopasuj kolumnę do widoku, 0 = wyśrodkuj)
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        animate_manual_resizes = false,
        animate_mouse_windowdragging = false,
        focus_on_activate = true,
        key_press_enables_dpms = true,
        mouse_move_enables_dpms = true,
    },

    binds = {
        -- Win+strzałka nie przeskakuje na inny monitor
        window_direction_monitor_fallback = false,
        -- NOWE: gdy aktywne jest okno na pełnym ekranie (fullscreen jest teraz
        -- częścią taśmy scrolling), strzałki nadal zmieniają okna, a nie
        -- "szukają monitora" (bez tego przy fallback=false nic by się nie działo)
        movefocus_cycles_fullscreen = true,
    },

    cursor = {
        hide_on_key_press = true,
        hide_on_tablet = true,
        inactive_timeout = 0,
        no_hardware_cursors = true,
        no_warps = false,
        persistent_warps = true,
        zoom_factor = 1.0,
    },

    ecosystem = {
        enforce_permissions = false,
        no_donation_nag = true,
        no_update_news = true,
    },

    xwayland = {
        force_zero_scaling = false,
    },
})

------------------------------------
-- REGUŁY OKIEN I OBSZARY ROBOCZE --
------------------------------------
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})

hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
for i = 2, 9 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1" })
end
hl.workspace_rule({ workspace = "10", monitor = "HDMI-A-1", default = true })

------------------
-- SKRÓTY KLAWISZY --
------------------

-- Aplikacje (Shift + litera)
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("zeditor ~/NixOS-config"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd([[google-chrome-stable --app="https://www.disneyplus.com"]]))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("firefoxpwa site launch 01KXGEAFP9PVEPGE076912VFFW"))  -- Gemini
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd("firefoxpwa site launch 01M5AYH12GTA7BZCE3EMRSKWCM"))  -- Homepage
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd("firefoxpwa site launch 01KXC864P5YP28H2ZKWJZJ6BBX"))  -- Ekursy
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("localsend_app"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("firefoxpwa site launch 01KXGE92QTY967Q9R6PRYKBNEK"))  -- Gmail
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd([[google-chrome-stable --app="https://www.netflix.com"]]))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("firefoxpwa site launch 01KXGE7F4WDSED8ZDNMDXWHWBM"))  -- Gdrive
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("firefoxpwa site launch 01KXGEJXRN8BZDN7T6E3YRKCMG"))  -- Messenger
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("vesktop"))
hl.bind(mainMod .. " + SHIFT + Y", hl.dsp.exec_cmd([[google-chrome-stable --app="https://www.youtube.com"]]))

-- Podstawowe
-- fullscreen, 0 = pełny ekran (przykrywa też Waybara)
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + W", hl.dsp.window.close())
-- hyprctl dispatch przyjmuje teraz wyrażenie Lua
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(
    [[command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()']]
))
hl.bind(mainMod .. " + P", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))  -- uwaga: to komunikat układu dwindle, w scrolling nic nie robi
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd(powermenu))

-- Nawigacja oknami (strzałki)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Przenoszenie okien w wybranym kierunku
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Precyzyjne proporcje kolumny (layoutmsg -> hl.dsp.layout)
hl.bind(mainMod .. " + ALT + 1", hl.dsp.layout("colresize 0.25"))
hl.bind(mainMod .. " + ALT + 2", hl.dsp.layout("colresize 0.33"))
hl.bind(mainMod .. " + ALT + 3", hl.dsp.layout("colresize 0.50"))
hl.bind(mainMod .. " + ALT + 4", hl.dsp.layout("colresize 0.66"))
hl.bind(mainMod .. " + ALT + 5", hl.dsp.layout("colresize 0.75"))
hl.bind(mainMod .. " + ALT + 6", hl.dsp.layout("colresize 1.0"))

-- Płynna zmiana szerokości aktywnej kolumny
hl.bind(mainMod .. " + minus", hl.dsp.layout("colresize -0.1"))
hl.bind(mainMod .. " + equal", hl.dsp.layout("colresize +0.1"))

-- Napraw układ po powiększeniu okna
hl.bind(mainMod .. " + E",          hl.dsp.layout("fit visible"))        -- widoczne kolumny wypełniają ekran
hl.bind(mainMod .. " + CTRL + E",   hl.dsp.layout("colresize all 0.5"))  -- wszystkie kolumny po 50%

-- Obszary robocze 1-10 (klawisz 0 = obszar 10)
for i = 1, 10 do
    local key = i % 10

    -- Przełączanie
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))

    -- Przeniesienie okna (z przejściem za nim)
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))

    -- "Ciche" przeniesienie okna (bez podążania za nim)
    hl.bind(mainMod .. " + SHIFT + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Scratchpad (magiczny obszar roboczy)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Zmiana obszarów rolką myszy
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Przenoszenie i zmiana rozmiaru myszką
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Jasność (bindel = locked + repeating)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("~/.config/Scripts/brightness.sh up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("~/.config/Scripts/brightness.sh down"), { locked = true, repeating = true })

-- Głośność
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"),       { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })

-- Mikrofon
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("~/.config/Scripts/mic.sh"), { locked = true })
hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --input-volume raise --max-volume 100"), { locked = true, repeating = true })
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --input-volume lower"),                  { locked = true, repeating = true })

-- Multimedia
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Zrzuty ekranu
-- Obszar -> Swappy (rysowanie strzałek, cenzurowanie)
hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | swappy -f -]]))

-- Obszar -> zapis do pliku ORAZ schowek
hl.bind("Print", hl.dsp.exec_cmd(
    [[sh -c 'grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/screen_$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy']]
))

-- Cały ekran -> zapis do pliku ORAZ schowek
hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    [[sh -c 'grim - | tee ~/Pictures/Screenshots/screen_$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy']]
))

-- Schowek (Walker + Elephant)
hl.bind("SUPER + CTRL + V", hl.dsp.exec_cmd("~/.config/Scripts/launch-walker.sh -m clipboard"), { description = "Clipboard manager" })
