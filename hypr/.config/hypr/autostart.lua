-- Programs to launch automatically when Hyprland starts.
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function ()
  -- Per primo: ripristina dalla cache l'ultimo sfondo, e deve avere il
  -- socket pronto prima che qualcuno provi a cambiarlo.
  hl.exec_cmd("awww-daemon")

  hl.exec_cmd("spotify-launcher")
  hl.exec_cmd("discord")
  hl.exec_cmd("quickshell")
end)
