// Drawers.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland


Singleton {
  id: root

  // "" = chiuso. Altrimenti il nome del cassetto aperto: e' l'intenzione.
  // Uno alla volta, perche' il focus grab e' uno solo.
  property string current: ""

  // Nomi delle finestre vive. Durante uno scambio ce ne sono due: una
  // esce mentre l'altra entra.
  property var loaded: []

  // Fotografato all'apertura, non seguito con un binding: se cambiassi
  // output mentre e' aperto, il pannello salterebbe da uno schermo all'altro.
  property var screen: null

  // Scritta dalle finestre. Tiene vivo il pannello finche' ci stai sopra.
  property bool hovered: false

  // Handle delle finestre per nome. Non serve un binding: lo legge il grab.
  readonly property var windows: ({})

  function isOpen(name)   { return root.current === name }
  function isLoaded(name) { return root.loaded.indexOf(name) !== -1 }

  // Riassegnazione dell'array intero: mutarlo sul posto non notifica i binding.
  function setLoaded(name, v) {
    const l = root.loaded.slice()
    const i = l.indexOf(name)
    if (v && i === -1) l.push(name)
    else if (!v && i !== -1) l.splice(i, 1)
    else return
    root.loaded = l
  }

  // HyprlandMonitor e Quickshell.screens sono due modelli separati.
  // Il ponte fra i due e' il nome dell'output.
  function screenFor(monitor) {
    if (!monitor) return null
    for (const s of Quickshell.screens)
      if (s.name === monitor.name) return s
    return null
  }

  // screen esplicito quando l'apertura parte dalla barra: su un layer
  // surface il focusedMonitor puo' non seguire il mouse, e il pannello
  // nascerebbe sul monitor sbagliato.
  function open(name, screen) {
    const s = screen ?? root.screenFor(Hyprland.focusedMonitor)

    if (!s) {
      console.warn("Drawers: nessuno schermo per", name)
      return
    }

    root.screen = s

    // Ordine obbligato: la finestra deve esistere prima di chiederle di
    // mostrarsi, altrimenti nasce gia' aperta e l'entrata non si vede.
    root.setLoaded(name, true)
    root.current = name
  }

  function close() { root.current = "" }

  function toggle(name, screen) {
    if (root.isOpen(name)) root.close()
    else root.open(name, screen)
  }

  // Chiamata dalla finestra a fine animazione di uscita. La guardia copre
  // la riapertura a meta' uscita: li' la finestra serve ancora.
  function unload(name) {
    if (root.current !== name) {
      delete root.windows[name]
      root.setLoaded(name, false)
    }
  }

  // Il grab segue l'apertura, non la nascita della finestra: le finestre
  // sopravvivono alle chiusure e onCompleted gira una volta sola.
  onCurrentChanged: {
    if (root.current !== "") {
      const w = root.windows[root.current]
      grab.windows = w ? [w] : []
      grabDelay.restart()
    } else {
      grab.active = false
      grab.windows = []
      root.hovered = false
    }
  }

  // ── Chiusura al click fuori ─────────────────────────────────────────
  HyprlandFocusGrab {
    id: grab
    windows: []
    active: false

    onCleared: root.close()
  }

  // Registra la finestra e, se quel cassetto e' gia' aperto, riarma il
  // grab: copre il caso in cui LazyLoader costruisca dopo l'apertura.
  function registerWindow(name, win) {
    root.windows[name] = win
    if (root.current === name) {
      grab.windows = [win]
      grabDelay.restart()
    }
  }

  // Il grab non puo' partire subito: alla Component.onCompleted la
  // superficie Wayland non e' ancora mappata, Hyprland vede il focus
  // altrove ed emette cleared all'istante.
  Timer {
    id: grabDelay
    interval: 50
    // Due guardie: il cassetto puo' essere gia' chiuso, o la finestra non nata.
    onTriggered: if (root.current !== "" && grab.windows.length > 0) grab.active = true
  }

  // ── Chiusura per inattivita' ────────────────────────────────────────
  readonly property int autoCloseTimeout: Config.drawer?.autoCloseTimeout ?? 0

  Timer {
    interval: root.autoCloseTimeout > 0 ? root.autoCloseTimeout : 1000

    // Fermo mentre ci passi sopra: il conto riparte da zero quando esci,
    // cosi' il pannello non ti muore sotto le mani mentre lo usi.
    running: root.current !== "" && !root.hovered && root.autoCloseTimeout > 0

    onTriggered: root.close()
  }

  // ── Ingressi esterni ────────────────────────────────────────────────
  IpcHandler {
    target: "drawers"

    function toggle(drawer: string): void { root.toggle(drawer) }
    function open(drawer: string):   void { root.open(drawer) }
    function close():                void { root.close() }
  }

  GlobalShortcut {
    appid: "quickshell"
    name: "drawerToggle"
    description: "Apre e chiude il launcher"

    onPressed: root.toggle("launcher")
  }

  GlobalShortcut {
    appid: "quickshell"
    name: "dashboardToggle"
    description: "Apre e chiude audio e sessione"

    onPressed: root.toggle("dashboard")
  }
}
