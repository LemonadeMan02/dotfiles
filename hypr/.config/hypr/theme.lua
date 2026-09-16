-- Colori generati da matugen; se mancano restano i valori statici di hyprland.lua

local ok, colors = pcall(function()
    return dofile(os.getenv("HOME") .. "/.local/state/hypr/colors.lua")
end)

-- File assente, API non disponibile o contenuto inatteso: ripiego silenzioso
if not ok or type(colors) ~= "table" or type(colors.active_border) ~= "string" then
    return
end

hl.config({
    general = {
        col = {
            active_border = colors.active_border,
        },
    },
})
