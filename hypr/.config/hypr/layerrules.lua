-- Regole per le superfici layer-shell (barre, launcher, notifiche).
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.layer_rule({
    name  = "quickshell-bar-blur",
    match = { namespace = "^quickshell:bar$" },

    blur = true,

    -- Sotto questa alpha un pixel non viene sfocato: senza, si sfoca anche lo spazio vuoto tra le pill
    ignore_alpha = 0.3,
})

hl.layer_rule({
    name  = "quickshell-drawer",
    match = { namespace = "^quickshell:drawer$" },

    blur = true,
    ignore_alpha = 0.3,

    -- I drawer si animano da soli in Drawer.qml: il fade di Hyprland si sommerebbe
    no_anim = true,
})

hl.layer_rule({
    name  = "quickshell-notifications",
    match = { namespace = "^quickshell:notifications$" },

    blur = true,
    ignore_alpha = 0.3,

    -- Le card entrano in dissolvenza da sole in NotificationPopups.qml
    no_anim = true,
})
