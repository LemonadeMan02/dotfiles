-- Colori dei bordi: palette di matugen se valida, altrimenti Catppuccin Mocha

-- Ripiego statico: mauve attivo, bordo inattivo trasparente
local fallback = {
    active_border   = "rgba(cba6f7ff)",
    inactive_border = "rgba(00000000)",
}

-- pcall: file assente o con errori non deve rompere la config di Hyprland
local ok, generated = pcall(function()
    return dofile(os.getenv("HOME") .. "/.local/state/hypr/colors.lua")
end)

-- Valida solo se e' una tabella con una stringa dove ci serve
local valid = ok and type(generated) == "table"
              and type(generated.active_border) == "string"

hl.config({
    general = {
        col = {
            active_border   = valid and generated.active_border or fallback.active_border,
            inactive_border = fallback.inactive_border,
        },
    },
})
