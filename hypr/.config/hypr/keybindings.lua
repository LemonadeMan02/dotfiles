-- Keybindings
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "hyprlauncher"
local browser     = "firefox"

local mainMod = "SUPER" -- Sets "Windows" key as main modifier


-----------------------
---- LAUNCH APPS ------
-----------------------

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))    -- Terminal
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager)) -- File manager
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))     -- Browser
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))        -- App launcher / menu


-------------------------
---- WINDOW CONTROL -----
-------------------------

local closeWindowBind = hl.bind(mainMod .. " + W", hl.dsp.window.close()) -- Close focused window
-- closeWindowBind:set_enabled(false)

hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" })) -- Toggle floating
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())                     -- Toggle pseudotiling
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))               -- Toggle split (dwindle only)

hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(
    "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"
)) -- Session exit / power menu


------------------------
---- FOCUS MOVEMENT ----
------------------------

hl.bind(mainMod .. " + CTRL + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",           hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",         hl.dsp.focus({ direction = "down" }))


-------------------
---- MOUSE --------
-------------------

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


---------------------------
---- MEDIA / HARDWARE -----
---------------------------

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
