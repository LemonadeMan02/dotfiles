// Drawers.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland


Singleton {
  id: root

  // Due stati distinti. "visible" e' l'intenzione: aperto o chiuso.
  // "loaded" e' la finestra viva, e sopravvive alla chiusura per il tempo
  // dell'animazione di uscita.
  property bool visible: false
  property bool loaded: false

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

    // Ordine obbligato: la finestra deve esistere prima di chiederle di
    // mostrarsi, altrimenti nasce gia' aperta e l'entrata non si vede.
    root.loaded = true
    root.visible = true
  }

  function close() {
    root.visible = false
  }

  function toggle() {
    if (root.visible) root.close()
    else root.open()
  }

  // Chiamata dalla finestra a fine animazione di uscita. La guardia copre
  // la riapertura a meta' uscita: li' la finestra serve ancora.
  function unload() {
    if (!root.visible) {
      grab.windows = []
      root.loaded = false
    }
  }

  // Il grab segue l'apertura, non la nascita della finestra: ora la
  // finestra sopravvive alle chiusure e onCompleted gira una volta sola.
  onVisibleChanged: {
    if (root.visible) {
      grabDelay.restart()
    } else {
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

  // Registra la finestra e, se il drawer e' gia' aperto, riarma il grab:
  // copre il caso in cui LazyLoader costruisca dopo l'apertura.
  function registerWindow(win) {
    grab.windows = [win]
    if (root.visible) grabDelay.restart()
  }

  // Il grab non puo' partire subito: alla Component.onCompleted la
  // superficie Wayland non e' ancora mappata, Hyprland vede il focus
  // altrove ed emette cleared all'istante.
  Timer {
    id: grabDelay
    interval: 50
    // Due guardie: la finestra puo' essere gia' chiusa, o non ancora nata.
    onTriggered: if (root.visible && grab.windows.length > 0) grab.active = true
  }

  // ── Chiusura per inattivita' ────────────────────────────────────────
  readonly property int autoCloseTimeout: Config.drawer?.autoCloseTimeout ?? 0

  Timer {
    interval: root.autoCloseTimeout > 0 ? root.autoCloseTimeout : 1000

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
