-- Workspace management: which monitor each workspace is pinned to, plus the
-- keybindings used to switch between workspaces and move windows to them.
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
--     https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-----------------------
---- MONITOR PINS -----
-----------------------

-- Descrizione invece del connettore: DP-1 e HDMI-A-1 cambiano se sposti un cavo
-- Stesse stringhe di hl.monitor in hyprland.lua: vanno aggiornate insieme
local primary   = "desc:Dell Inc. AW3225QF"
local secondary = "desc:LG Electronics LG ULTRAGEAR"

-- "persistent" tiene il workspace sul monitor anche vuoto, "default" lo mostra all'avvio
hl.workspace_rule({ workspace = "1", monitor = primary,   persistent = true, default = true })
hl.workspace_rule({ workspace = "2", monitor = secondary, persistent = true, default = true })


----------------------
---- KEYBINDINGS ------
----------------------

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Switch workspaces with mainMod + left/right (next/previous existing workspace)
hl.bind(mainMod .. " + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + left",  hl.dsp.focus({ workspace = "e-1" }))
