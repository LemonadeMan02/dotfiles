// Anteprima di LockContent in una finestra normale: nessun blocco, nessun PAM.
// Avvio: quickshell -p ~/.config/quickshell/lock-preview.qml
import Quickshell
import QtQuick
import "./modules/lock"

ShellRoot {
  FloatingWindow {
    title: "lock-preview"
    implicitWidth: 1280
    implicitHeight: 720

    LockContent {
      id: content
      anchors.fill: parent
      text: ""
      // Invio con il campo pieno simula una password errata.
      onEdited: t => content.text = t
      onSubmitted: { content.text = ""; content.errorText = "Wrong password" }
    }
  }
}
