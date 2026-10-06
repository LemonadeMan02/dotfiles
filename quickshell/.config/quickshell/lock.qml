// lock.qml
// Schermata di blocco: processo separato dalla shell, stessi servizi.
// Avvio: quickshell -p ~/.config/quickshell/lock.qml
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick
import QtQuick.Effects
import "./services"
import "./modules/common"

ShellRoot {
  id: root

  // Condiviso tra i monitor: ogni superficie ha il suo campo, il testo e' uno solo.
  property string currentText: ""
  property string errorText: ""
  // File segnale: qs-lock.service lo aspetta prima di risultare avviato,
  // cosi' barra e sfondo (Before= nel servizio) partono a schermo gia' coperto
  readonly property string readyFile: Quickshell.env("XDG_RUNTIME_DIR") + "/qs-lock.ready"

  // Da Config e non da Wallpapers: quel singleton scansiona la cartella e puo'
  // lanciare matugen, qui basta il path dell'immagine che awww sta mostrando.
  readonly property string wallpaperUrl: {
    const w = Config.appearance?.wallpaper ?? ""
    return w !== "" ? "file://" + w : ""
  }

  // Gli id dentro il delegato non si vedono da qui: i campi ascoltano questo per la scossa.
  signal rejected()

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
        root.rejected()
      }
    }
  }

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
      // Colore pieno finche' lo sfondo non e' decodificato, o se non ce n'e' uno.
      color: Theme.c.base

      // Misura fissa e non dello schermo: i due monitor chiedono la stessa
      // immagine e Qt la decodifica una volta sola. Sotto la sfocatura basta.
      Image {
        id: wall
        anchors.fill: parent
        source: root.wallpaperUrl
        sourceSize: Qt.size(1920, 1080)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
      }

      Item {
        anchors.fill: parent
        // Entra in dissolvenza a decodifica finita, invece di comparire a scatto
        opacity: wall.status === Image.Ready ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: Theme.durSlow } }

        MultiEffect {
          anchors.fill: parent
          source: wall
          blurEnabled: true
          blur: 1.0
          blurMax: 48
          // Senza, i bordi sfocati sfumano verso il trasparente
          autoPaddingEnabled: false
        }

        // Velo col fondo del tema, non Theme.scrim: nero sotto un testo scuro
        // sarebbe illeggibile col tema chiaro.
        Rectangle {
          anchors.fill: parent
          color: Theme.withAlpha(Theme.c.base, 0.55)
        }
      }

      Column {
        anchors.centerIn: parent
        spacing: Theme.spacingM

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: Time.time
          color: Theme.foreground
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontDisplay
          font.weight: Theme.weightBold
        }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: Time.date
          color: Theme.foregroundDim
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontL
          font.weight: Theme.weightNormal
        }

        // Stacco fra data e campo
        Item { width: 1; height: Theme.spacingL * 3 }

        SearchField {
          id: field
          anchors.horizontalCenter: parent.horizontalCenter
          width: 360
          implicitHeight: 48

          icon: Icons.lock
          placeholder: "Password"
          echoMode: TextInput.Password
          // readOnly e non enabled: disabilitato perderebbe il focus durante il controllo
          readOnly: pam.active

          // Bordo interattivo nel colore d'accento; rosso solo per l'errore
          border.width: 2
          border.color: root.errorText !== "" ? Theme.urgent : Theme.surfaceAccent

          Behavior on border.color { ColorAnimation { duration: Theme.durFast } }

          text: root.currentText
          onTextChanged: {
            root.currentText = text
            // Il rosso resta finche' non si ricomincia a scrivere
            if (text !== "") root.errorText = ""
          }
          onAccepted: root.tryUnlock()
          onCancelled: root.currentText = ""

          Component.onCompleted: field.forceFocus()

          // Scossa al rifiuto, solo in orizzontale
          SequentialAnimation {
            id: shake
            loops: 2
            NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -10; duration: 40 }
            NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 10; duration: 80 }
            NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 0; duration: 40 }
          }

          Connections {
            target: root
            function onRejected() { shake.restart() }
          }
        }

        // Altezza fissa: comparendo il messaggio non sposta orologio e campo
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          height: Theme.fontM * 2
          verticalAlignment: Text.AlignVCenter
          text: pam.active ? "Checking…" : root.errorText
          color: root.errorText !== "" && !pam.active ? Theme.urgent : Theme.foregroundDim
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontM
          font.weight: Theme.weightBold
        }
      }
    }
  }
}
