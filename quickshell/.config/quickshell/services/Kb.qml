// Keyboard.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Singleton {
  id: root

  // Nome esteso di xkb, es. "English (UK)": non il codice "gb" della config.
  property string keymap: ""

  // Due lettere dal nome esteso: basta finche' i layout sono lingue diverse.
  readonly property string code: keymap ? keymap.slice(0, 2).toUpperCase() : ""

  // Stato iniziale: Hyprland manda eventi solo ai cambi.
  Process {
    running: true
    command: ["hyprctl", "devices", "-j"]

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const kbs = JSON.parse(text).keyboards
          const main = kbs.find(k => k.main) ?? kbs[0]
          if (main) root.keymap = main.active_keymap
        } catch (e) {
          console.warn("Kb: output di hyprctl illeggibile:", e)
        }
      }
    }
  }

  // activelayout>>TASTIERA,LAYOUT; parse(2) protegge eventuali virgole nel nome.
  Connections {
    target: Hyprland

    function onRawEvent(event) {
      if (event.name !== "activelayout") return
      root.keymap = event.parse(2)[1]
    }
  }
}
