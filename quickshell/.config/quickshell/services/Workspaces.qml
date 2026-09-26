// Workspaces.qml
pragma Singleton

import Quickshell
import Quickshell.Hyprland


Singleton {
  id: root

  // Posti per monitor: da tenere uguale a workspaces_per_monitor in hypr/monitors.lua.
  readonly property int perMonitor: 5

  // Appoggio dello scambio: speciale, quindi non compare su nessuno schermo.
  readonly property string swapStash: "special:swap"

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

  // Ordine di lettura, dall'alto a sinistra: e' l'ordine in cui dwindle le disporrebbe da solo.
  // Senza posizione nota una finestra va in fondo, invece di rompere il confronto con NaN.
  function readingOrder(p, q) {
    const a = p.lastIpcObject?.at
    const b = q.lastIpcObject?.at
    if (!a && !b) return 0
    if (!a) return 1
    if (!b) return -1
    return a[1] !== b[1] ? a[1] - b[1] : a[0] - b[0]
  }

  // Indirizzi delle finestre di un workspace in ordine di lettura; vuoto se non esiste.
  function addressesOf(id) {
    const ws = root.byId(id)
    if (!ws) return []
    return ws.toplevels.values
      .filter(t => t.address !== "")
      .sort(root.readingOrder)
      .map(t => t.address)
  }

  // Solo forma Lua: activate() di HyprlandWorkspace usa la vecchia sintassi "workspace N".
  function focus(id) {
    Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })")
  }

  // Sposta una finestra senza seguirla. Campo sbagliato = ignorato: sposterebbe quella attiva.
  // Un id numerico va scritto nudo, un nome come "special:swap" tra virgolette.
  function moveWindow(address, target) {
    if (!address) return
    const a = address.startsWith("0x") ? address : "0x" + address
    const ws = typeof target === "number" ? String(target) : "\"" + target + "\""
    Hyprland.dispatch("hl.dsp.window.move({ workspace = " + ws
                      + ", follow = false, window = \"address:" + a + "\" })")
  }

  // Tre tempi con un appoggio nascosto: ogni workspace riceve le finestre quando e' gia' vuoto,
  // cosi' dwindle le ridispone da zero nell'ordine originale invece di infilarle fra le altre.
  function swap(a, b) {
    const fromA = root.addressesOf(a)
    const fromB = root.addressesOf(b)
    for (const x of fromA) root.moveWindow(x, root.swapStash)
    for (const x of fromB) root.moveWindow(x, a)
    for (const x of fromA) root.moveWindow(x, b)
  }
}
