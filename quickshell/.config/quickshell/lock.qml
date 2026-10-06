// lock.qml
// Schermata di blocco: processo separato dalla shell, stessi servizi.
// Avvio: quickshell -p ~/.config/quickshell/lock.qml
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick
import "./services"
import "./modules/lock"

ShellRoot {
  id: root

  // Condiviso tra i monitor: ogni superficie ha il suo campo, il testo e' uno solo.
  property string currentText: ""
  property string errorText: ""
  // File segnale: qs-lock.service lo aspetta prima di risultare avviato,
  // cosi' barra e sfondo (Before= nel servizio) partono a schermo gia' coperto
  readonly property string readyFile: Quickshell.env("XDG_RUNTIME_DIR") + "/qs-lock.ready"

  function tryUnlock() {
    if (pam.active || root.currentText === "") return
    root.errorText = ""
    pam.start()
  }

  function unlock() {
    lock.locked = false
    // Uscire subito potrebbe chiudere la connessione prima che il compositore
    // riceva lo sblocco: la sessione resterebbe bloccata con il locker morto.
    quitTimer.start()
  }

  PamContext {
    id: pam
    config: "qs-lock"

    // PAM chiede la password: rispondiamo con il testo digitato.
    onPamMessage: {
      if (this.responseRequired) this.respond(root.currentText)
    }

    onCompleted: result => {
      if (result === PamResult.Success) {
        root.unlock()
      } else {
        root.errorText = "Wrong password"
        root.currentText = ""
      }
    }
  }

  // Uscita ritardata: vedi unlock().
  Timer {
    id: quitTimer
    interval: 300
    onTriggered: Qt.quit()
  }

  WlSessionLock {
    id: lock
    locked: true
    // secure: il compositore conferma che tutti i monitor sono coperti
    onSecureChanged: if (secure) Quickshell.execDetached(["touch", root.readyFile])

    // Delegato: il compositore ne crea una per ogni monitor.
    WlSessionLockSurface {
      LockContent {
        anchors.fill: parent
        text: root.currentText
        errorText: root.errorText
        busy: pam.active
        onEdited: t => root.currentText = t
        onSubmitted: root.tryUnlock()
        onRebootRequested: Session.reboot()
        onShutdownRequested: Session.shutdown()
      }
    }
  }
}
