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
      // Invio simula una password errata. errorText si svuota prima, come in
      // lock.qml: senza cambio di valore dal secondo errore non scuoterebbe.
      onEdited: t => content.text = t
      onSubmitted: {
        content.errorText = ""
        content.text = ""
        content.errorText = "Wrong password"
      }
      // Solo un messaggio: nell'anteprima i tasti non devono spegnere niente.
      onRebootRequested: console.log("lock-preview: reboot")
      onShutdownRequested: console.log("lock-preview: shutdown")
    }
  }
}
