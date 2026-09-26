-- Unica fonte dei monitor: hyprland.lua li configura, workspaces.lua ci lega i workspace
-- desc: invece del connettore: DP-1 e HDMI-A-1 cambiano se sposti un cavo

local M = {}

-- Primario: Dell AW3225QF su DisplayPort, 4K
M.primary = {
    output   = "desc:Dell Inc. AW3225QF",
    mode     = "3840x2160@239.99",
    position = "0x0",
    scale    = 1.25,
}

-- Secondario: LG UltraGear su HDMI, 1440p; x = 3840 / 1.25
M.secondary = {
    output   = "desc:LG Electronics LG ULTRAGEAR",
    mode     = "2560x1440@74.97",
    position = "3072x0",
    scale    = 1,
}

-- Ordine dei blocchi di workspace: il primo monitor ha 1-5, il secondo 6-10
M.ordered = { M.primary, M.secondary }

-- Posti per monitor; da tenere uguale a perMonitor in quickshell/services/Workspaces.qml
-- (e alla larghezza della panoramica in quickshell/shell.qml, calcolata per 5 miniature)
M.workspaces_per_monitor = 5

return M
