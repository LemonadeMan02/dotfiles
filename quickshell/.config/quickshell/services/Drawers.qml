// Drawers.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland


Singleton {
  id: root

  property bool visible: false

  // Fotografato all'apertura, non seguito con un binding: se cambiassi
  // output mentre e' aperto, il drawer salterebbe da uno schermo all'altro.
  property var screen: null

  // Scritta dal Drawer. Tiene vivo il pannello finche' ci stai sopra.
  property bool hovered: false

  // HyprlandMonitor e Quickshell.screens sono due modelli separati.
  // Il ponte fra i due e' il nome dell'output.
  function screenFor(monitor) {
    if (!monitor) return null
    for (const s of Quickshell.screens)
      if (s.name === monitor.name) return s
    return null
  }

  function open() {
    const mon = Hyprland.focusedMonitor
    root.screen = root.screenFor(mon)

    if (!root.screen) {
      console.warn("Drawers: nessuno schermo per il monitor",
                   mon ? mon.name : "(focusedMonitor null)")
      return
    }

    root.visible = true
  }

  function close() {
    root.visible = false
  }

  function toggle() {
    if (root.visible) root.close()
    else root.open()
  }

  onVisibleChanged: {
    if (!root.visible) {
      grab.active = false
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

  // Il grab non puo' partire subito: alla Component.onCompleted la
  // superficie Wayland non e' ancora mappata, Hyprland vede il focus
  // altrove ed emette cleared all'istante.
  function registerWindow(win) {
    grab.windows = [win]
    grabDelay.restart()
  }

  Timer {
    id: grabDelay
    interval: 50
    // La guardia serve: se chiudi entro l'intervallo, senza di essa
    // attiveresti un grab su una finestra gia' distrutta.
    onTriggered: if (root.visible) grab.active = true
  }

  // ── Chiusura per inattivita' ────────────────────────────────────────
  readonly property int autoCloseTimeout: Config.drawer?.autoCloseTimeout ?? 0

  Timer {
    interval: root.autoCloseTimeout > 0 ? root.autoCloseTimeout : 20

    // Fermo mentre ci passi sopra: il conto riparte da zero quando esci,
    // cosi' il pannello non ti muore sotto le mani mentre lo usi.
    running: root.visible && !root.hovered && root.autoCloseTimeout > 0

    onTriggered: root.close()
  }

  // ── Ingressi esterni ────────────────────────────────────────────────
  IpcHandler {
    target: "drawers"

    function toggle(): void { root.toggle() }
    function open():   void { root.open() }
    function close():  void { root.close() }
  }

  GlobalShortcut {
    appid: "quickshell"
    name: "drawerToggle"
    description: "Apre e chiude il drawer"

    onPressed: root.toggle()
  }
}
