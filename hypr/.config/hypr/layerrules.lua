-- Regole per le superfici layer-shell (barre, launcher, notifiche).
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.layer_rule({
    name  = "quickshell-bar-blur",
    match = { namespace = "^quickshell:bar$" },

    blur = true,

    -- Soglia sotto la quale un pixel NON viene sfocato. Senza questa riga
    -- Hyprland sfoca l'intera superficie del layer, cioe' anche lo spazio
    -- vuoto tra le pill: ti ritrovi una fascia sfocata larga quanto lo
    -- schermo. Va tenuta sotto pillAlpha (0.70) e sopra 0.
    ignore_alpha = 0.3,
})

hl.layer_rule({
    name  = "quickshell-drawer-blur",
    match = { namespace = "^quickshell:drawer$" },

    blur = true,
    ignore_alpha = 0.3,
})
