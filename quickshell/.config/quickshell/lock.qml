// lock.qml
// Schermata di blocco: processo separato dalla shell, stessi servizi.
// Avvio: quickshell -p ~/.config/quickshell/lock.qml
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick
import "./services"

ShellRoot {
  id: root

  property bool devMode: false

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

  WlSessionLock {
    id: lock
    locked: true
    // secure: il compositore conferma che tutti i monitor sono coperti
    onSecureChanged: if (secure) Quickshell.execDetached(["touch", root.readyFile])

    // Delegato: il compositore ne crea una per ogni monitor.
    WlSessionLockSurface {
      Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"

        Column {
          anchors.centerIn: parent
          spacing: Theme.spacingM

          Rectangle {
            width: 360
            height: 48
            radius: Theme.radiusS
            color: "#313244"

            TextInput {
              id: input
              anchors.fill: parent
              anchors.margins: Theme.spacingM
              verticalAlignment: TextInput.AlignVCenter
              horizontalAlignment: TextInput.AlignHCenter
              focus: true
              enabled: !pam.active
              echoMode: TextInput.Password
              color: "#cdd6f4"
              font.family: "JetBrainsMono Nerd Font"
              font.pixelSize: 18

              text: root.currentText
              onTextChanged: root.currentText = text
              onAccepted: root.tryUnlock()
            }
          }

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: pam.active ? "Checking…" : root.errorText
            // Rosso: semantica riservata agli errori
            color: root.errorText !== "" && !pam.active ? "#f38ba8" : "#a6adc8"
            font.family: "JetBrainsMono Nerd Font"
            font.weight: Theme.weightBold
            font.pixelSize: 14
          }
        }
      }
    }
  }
}
