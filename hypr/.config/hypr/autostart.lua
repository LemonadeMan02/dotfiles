-- Programs to launch automatically when Hyprland starts.
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- awww, hypridle e quickshell sono servizi systemd utente (pacchetto systemd/): qui solo le app

local scripts = os.getenv("HOME") .. "/.local/bin/"

hl.on("hyprland.start", function ()
  -- uwsm app: ogni app nel suo scope, fuori dal servizio di Hyprland
  -- after-unlock: partono dopo la password del lock, a gnome-keyring gia' aperto
  -- (Discord ci tiene i suoi segreti: prima chiederebbe la password del keyring)
  hl.exec_cmd(scripts .. "after-unlock uwsm app -- spotify-launcher")
  hl.exec_cmd(scripts .. "after-unlock uwsm app -- discord")
end)
