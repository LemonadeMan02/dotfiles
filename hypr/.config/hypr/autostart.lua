-- Programs to launch automatically when Hyprland starts.
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- awww, hypridle e quickshell sono servizi systemd utente (pacchetto systemd/): qui solo le app

hl.on("hyprland.start", function ()
  -- Per prima: copre gli schermi finche' sfondo e barra non sono pronti, poi li svela.
  -- Fuori da uwsm app: dura un secondo e awww e quickshell la aspettano (session-intro)
  hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/session-intro")

  -- uwsm app: ogni app nel suo scope, fuori dal servizio di Hyprland
  hl.exec_cmd("uwsm app -- spotify-launcher")
  hl.exec_cmd("uwsm app -- discord")
end)
