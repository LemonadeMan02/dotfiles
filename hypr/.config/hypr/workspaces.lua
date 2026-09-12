-- Workspace management: which monitor each workspace is pinned to, plus the
-- keybindings used to switch between workspaces and move windows to them.
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
--     https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod = "SUPER" -- Sets "Windows" key as main modifier


-----------------------
---- MONITOR PINS -----
-----------------------

-- Pin workspace 1 to the primary DisplayPort monitor and workspace 2 to the
-- secondary HDMI monitor. "persistent" keeps them bound to that monitor even
-- when empty, "default" makes them the workspace shown when the monitor loads.
hl.workspace_rule({ workspace = "1", monitor = "DP-1",     persistent = true, default = true })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1", persistent = true, default = true })


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
