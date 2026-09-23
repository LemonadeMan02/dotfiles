-- Programs to launch automatically when Hyprland starts.
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- awww, hypridle e quickshell sono servizi systemd utente (pacchetto systemd/): qui solo le app

hl.on("hyprland.start", function ()
  -- uwsm app: ogni app nel suo scope, fuori dal servizio di Hyprland
  hl.exec_cmd("uwsm app -- spotify-launcher")
  hl.exec_cmd("uwsm app -- discord")
end)
