-- Workspace per monitor: riga dei numeri per il Dell (1-5), tastierino per l'LG (6-10).
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
--     https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod = "SUPER" -- Tasto Windows come modificatore principale

local monitors = require("monitors")
local per      = monitors.workspaces_per_monitor

-- Primo workspace del blocco i: 1 per il primo monitor, 6 per il secondo
local function first_of(i)
    return (i - 1) * per + 1
end

-- Un set di tasti per monitor, nello stesso ordine di monitors.ordered; almeno `per` tasti ciascuno
-- Tastierino per keycode: il nome cambia con NumLock e SHIFT (KP_2 diventa KP_Down)
local keys = {
    { "1", "2", "3", "4", "5" },
    { "code:87", "code:88", "code:89", "code:83", "code:84" }, -- tastierino 1-5
}


-----------------------
---- MONITOR PINS -----
-----------------------

-- Ogni workspace nasce sul monitor del suo blocco; solo il primo resta anche vuoto
for i, m in ipairs(monitors.ordered) do
    for n = 1, per do
        hl.workspace_rule({
            workspace  = tostring(first_of(i) + n - 1),
            monitor    = m.output,
            persistent = n == 1,
            default    = n == 1,
        })
    end
end


----------------------
---- KEYBINDINGS ------
----------------------

-- Il set di tasti sceglie il monitor: SUPER apre, SUPER + SHIFT ci sposta la finestra attiva
for i = 1, #monitors.ordered do
    for n = 1, per do
        local ws  = first_of(i) + n - 1
        local key = keys[i][n]
        hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = ws }))
        hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws }))
    end
end

-- Workspace speciale (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- m+1 / m-1: workspace esistente successivo/precedente, solo sul monitor attivo
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + right",      hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + left",       hl.dsp.focus({ workspace = "m-1" }))
