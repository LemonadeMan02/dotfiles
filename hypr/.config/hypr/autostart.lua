-- Programs to launch automatically when Hyprland starts.
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function ()
  hl.exec_cmd("spotify-launcher")
    hl.exec_cmd("discord")
  hl.exec_cmd("quickshell")
end)
