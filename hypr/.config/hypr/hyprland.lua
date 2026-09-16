------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- Primario: Dell AW3225QF su DisplayPort, 4K
hl.monitor({
    output   = "desc:Dell Inc. AW3225QF",
    mode     = "3840x2160@239.99",
    position = "0x0",
    scale    = 1.25,
})

-- Secondario: LG UltraGear su HDMI, 1440p; x = 3840 / 1.25
hl.monitor({
    output   = "desc:LG Electronics LG ULTRAGEAR",
    mode     = "2560x1440@74.97",
    position = "3072x0",
    scale    = 1,
})


-------------------
---- AUTOSTART ----
-------------------

require("autostart")

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Le modifiche ai permessi richiedono un riavvio di Hyprland, non un reload

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- See https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        -- gaps_out uguale al margine laterale della barra: finestre e pill allineate
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        col = {
            -- Ripiego statico (mauve Catppuccin); theme.lua lo sovrascrive col colore di matugen
            active_border   = "rgba(cba6f7ff)",
            -- Trasparente: le inattive sembrano senza bordo, la griglia non si sposta
            inactive_border = "rgba(00000000)",
        },

        resize_on_border = false,

        -- Leggi la pagina Tearing del wiki prima di attivarlo
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        -- Uguale a Theme.radiusM: finestre e pill condividono la stessa curva
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        -- Spento di proposito: con follow_mouse = 1 il dimming lampeggia al passaggio del mouse
        dim_inactive = false,

        shadow = {
            enabled      = true,
            range        = 20,
            render_power = 3,
            -- Formato 0xAARRGGBB: nero al 40%
            color        = 0x66000000,
        },

        blur = {
            enabled    = true,
            size       = 6,
            passes     = 3,
            vibrancy   = 0.1696,
            -- 1.0: il blur non scurisce piu' le pill della barra
            brightness = 1.0,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Dopo il blocco look: sovrascrive i colori statici con quelli di matugen, se presenti
require("theme")

-- Curve e animazioni in animations.lua
require("animations")

-- Regole dei layer (blur di barra e drawer) in layerrules.lua
require("layerrules")

-- Pin dei workspace ai monitor e relativi keybind in workspaces.lua
require("workspaces")

-- "Smart gaps": niente gaps con una sola finestra; decommenta tutto per usarlo
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        -- Niente wallpaper e logo di default: evita il flash prima che awww ripristini lo sfondo
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "gb",
        kb_variant = "extd",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        -- Da -1.0 a 1.0; 0 = nessuna modifica
        sensitivity = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Config per singolo dispositivo: see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/


---------------------
---- KEYBINDINGS ----
---------------------

-- Tutti i keybind in keybindings.lua
require("keybindings")


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Ignora le richieste di maximize delle app; i tuoi dispatcher funzionano comunque
local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

-- Corregge alcuni problemi di drag con XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Anche le layer rule restituiscono un handle
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Finestra di hyprland-run
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
