-- Workspace: a quale monitor e' legato ciascuno, e i keybind per cambiarli e spostarci finestre.
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
--     https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod = "SUPER" -- Tasto Windows come modificatore principale

-- Stessa tabella di hyprland.lua: require la carica una volta sola
local monitors = require("monitors")

-----------------------
---- MONITOR PINS -----
-----------------------

-- "persistent" tiene il workspace sul monitor anche vuoto, "default" lo mostra all'avvio
hl.workspace_rule({ workspace = "1", monitor = monitors.primary.output,   persistent = true, default = true })
hl.workspace_rule({ workspace = "2", monitor = monitors.secondary.output, persistent = true, default = true })


----------------------
---- KEYBINDINGS ------
----------------------

-- SUPER + [0-9] cambia workspace, SUPER + SHIFT + [0-9] ci sposta la finestra attiva
for i = 1, 10 do
    local key = i % 10 -- Il 10 va sul tasto 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Workspace speciale (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- SUPER + rotella: workspace esistente successivo/precedente
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- SUPER + frecce destra/sinistra: workspace esistente successivo/precedente
hl.bind(mainMod .. " + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + left",  hl.dsp.focus({ workspace = "e-1" }))
