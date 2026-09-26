-- Keybindings
-- See https://wiki.hypr.land/Configuring/Basics/Binds/
-- Workspace e scratchpad sono in workspaces.lua

---------------------
---- MY PROGRAMS ----
---------------------

-- Il launcher e' quello di Quickshell (SUPER+Space), non un programma esterno
local terminal    = "kitty"
local fileManager = "dolphin"
local browser     = "firefox"

-- Uscita ordinata: uwsm ferma i servizi della sessione e Hyprland per ultimo; niente dispatcher exit
local exitCmd = "uwsm stop"

-- Tasto Windows come modificatore principale
local mainMod = "SUPER"


-----------------------
---- LAUNCH APPS ------
-----------------------

-- uwsm app: ogni app nel suo scope, sopravvive al restart di Quickshell e Hyprland
local function app(cmd) return hl.dsp.exec_cmd("uwsm app -- " .. cmd) end

hl.bind(mainMod .. " + Return", app(terminal))    -- Terminale
hl.bind(mainMod .. " + E",      app(fileManager)) -- File manager
hl.bind(mainMod .. " + B",      app(browser))     -- Browser


-------------------------
---- QUICKSHELL ---------
-------------------------

-- Globali dichiarate in Drawers.qml come GlobalShortcut (appid "quickshell")
hl.bind(mainMod .. " + Space", hl.dsp.global("quickshell:drawerToggle"))    -- Launcher
hl.bind(mainMod .. " + D",     hl.dsp.global("quickshell:dashboardToggle")) -- Audio e sessione
hl.bind(mainMod .. " + Tab",   hl.dsp.global("quickshell:overviewToggle"))  -- Panoramica dei workspace


-------------------------
---- WINDOW CONTROL -----
-------------------------

hl.bind(mainMod .. " + W", hl.dsp.window.close())                      -- Chiude la finestra attiva
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" })) -- Floating on/off
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())                     -- Pseudotiling on/off
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))               -- Split orizzontale/verticale (solo dwindle)

-- Maximize: area utile, la barra resta visibile; verifica il nome del mode nella pagina Dispatchers
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "maximized" }))
-- Fullscreen reale: copre anche la barra
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(exitCmd))                  -- Uscita dalla sessione
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session")) -- Lock


------------------------
---- FOCUS MOVEMENT ----
------------------------

-- SUPER+left/right senza CTRL cambia workspace (workspaces.lua)
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",           hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",         hl.dsp.focus({ direction = "down" }))


-------------------
---- MOUSE --------
-------------------

-- Sposta e ridimensiona con SUPER + tasto sinistro/destro trascinando
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


---------------------------
---- MEDIA / HARDWARE -----
---------------------------

-- Niente tasti luminosita': monitor esterni (DDC/CI) e tastiera senza quei tasti

-- Volume: -l 1 blocca a 100%, come il clamp in Audio.qml
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
-- Toggle senza repeating: tenendo premuto lo stato lampeggerebbe
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })

-- Player scelto da Media.qml (Spotify prima): barra e tasti comandano sempre lo stesso
hl.bind("XF86AudioNext",  hl.dsp.global("quickshell:mediaNext"),      { locked = true })
hl.bind("XF86AudioPause", hl.dsp.global("quickshell:mediaPlayPause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.global("quickshell:mediaPlayPause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.global("quickshell:mediaPrevious"),  { locked = true })
