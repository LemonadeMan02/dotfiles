// Workspaces.qml
pragma Singleton

import Quickshell
import Quickshell.Hyprland


Singleton {
  id: root

  // Posti per monitor: da tenere uguale a workspaces_per_monitor in hypr/monitors.lua.
  readonly property int perMonitor: 5

  // Primo workspace del blocco, dedotto dal workspace attivo del monitor: 7 -> 6.
  // Niente lista di monitor copiata da monitors.lua: il blocco lo decide Hyprland.
  function baseFor(monitor) {
    const ws = monitor?.activeWorkspace ?? null
    if (ws === null || ws.id <= 0) return 1
    return Math.floor((ws.id - 1) / root.perMonitor) * root.perMonitor + 1
  }

  // Workspace per id, o null se Hyprland non l'ha ancora creato.
  function byId(id) {
    for (const w of Hyprland.workspaces.values)
      if (w.id === id) return w
    return null
  }

  // Solo forma Lua: activate() di HyprlandWorkspace usa la vecchia sintassi "workspace N".
  function focus(id) {
    Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })")
  }
}
