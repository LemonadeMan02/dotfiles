-- Hyprland del greeter: monitor, tastiera e Quickshell, nient'altro
-- Gira come utente greeter (la tua home non e' leggibile): niente require dalla config utente

-- Per primo: se una chiave piu' sotto desse errore, il greeter parte lo stesso.
-- greetd avvia la sessione solo quando il greeter termina: uscito Quickshell
-- (lo fa da solo dopo il login) si chiude anche Hyprland
hl.on("hyprland.start", function ()
    hl.exec_cmd("sh -c 'systemd-cat -t greeter-quickshell quickshell -p /etc/greetd/quickshell; pkill -u greeter -x Hyprland'")
end)

-- Copia di ~/.config/hypr/monitors.lua: da tenere uguale, il greeter deve avere la stessa scala
hl.monitor({
    output   = "desc:Dell Inc. AW3225QF",
    mode     = "3840x2160@239.99",
    position = "0x0",
    scale    = 1.25,
})

hl.monitor({
    output   = "desc:LG Electronics LG ULTRAGEAR",
    mode     = "2560x1440@74.97",
    position = "3072x0",
    scale    = 1,
})

hl.config({
    -- Stesso layout della sessione: la password si scrive con gli stessi tasti
    input = {
        kb_layout  = "gb",
        kb_variant = "extd",
    },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },
})

-- Niente finestre di novita' o donazioni sopra il login. pcall: se la versione installata
-- non conosce la sezione, l'errore resta qui
pcall(hl.config, {
    ecosystem = {
        no_update_news  = true,
        no_donation_nag = true,
    },
})
