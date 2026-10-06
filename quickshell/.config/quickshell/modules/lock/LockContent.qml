// LockContent.qml
import QtQuick
import QtQuick.Effects
import "../../services"
import "../common"


// Aspetto del lock, separato da WlSessionLock: si prova in una finestra normale
// senza bloccare la sessione. Lo stato lo tiene lock.qml, qui si legge soltanto.
Rectangle {
  id: root

  property string text: ""
  property string errorText: ""
  property bool busy: false

  signal edited(string text)
  signal submitted()
  // Le azioni le esegue chi istanzia: l'anteprima non deve spegnere il PC.
  signal rebootRequested()
  signal shutdownRequested()

  // Errore da mostrare: durante il controllo PAM vince "Checking…".
  readonly property bool failed: root.errorText !== "" && !root.busy

  // Avanzamento della scossa, da 0 a 1: a riposo vale 1 e lo spostamento e' nullo.
  property real shakeProgress: 1

  // Si vede solo se lo sfondo manca o non si e' ancora caricato.
  color: Theme.scrim

  // Oltre i bordi: il blur sfuma verso il trasparente, cosi' la sfumatura cade fuori schermo.
  readonly property int blurMax: 64

  // Stessi source, sourceSize e fillMode della copia in Wallpapers: una sola decodifica,
  // e piccola. Tanto va sfocata, e un PNG 4K a piena risoluzione rallenterebbe il lock.
  Image {
    id: wallpaper
    anchors.fill: parent
    anchors.margins: -root.blurMax
    visible: false
    source: Wallpapers.currentUrl
    sourceSize: Wallpapers.thumbSize
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
  }

  MultiEffect {
    anchors.fill: wallpaper
    source: wallpaper
    autoPaddingEnabled: false
    blurEnabled: true
    blur: 1.0
    blurMax: root.blurMax
  }

  // Velo nero come sulle miniature: vale con entrambi i temi.
  Rectangle {
    anchors.fill: parent
    color: Theme.withAlpha(Theme.scrim, 0.25)
  }

  // Scheda di sblocco e impegni di oggi, centrate insieme e alte uguali.
  Row {
    anchors.centerIn: parent
    spacing: Theme.spacingL

    // Scheda di sblocco: stessa superficie delle pill, il testo segue il tema.
    Rectangle {
      id: unlockCard
      width: content.implicitWidth + Theme.spacingL * 4
      height: content.implicitHeight + Theme.spacingL * 4
      radius: Theme.radiusM
      antialiasing: true
      color: Theme.surface
      border.color: Theme.border

      Column {
        id: content
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
          font.capitalization: Font.Capitalize
        }

        // Opacita' e non visible: lo spazio resta, e la scheda non cresce quando
        // il meteo arriva (al boot la rete puo' non esserci ancora).
        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: Theme.spacingM
          opacity: Weather.ready ? 1 : 0

          Behavior on opacity {
            NumberAnimation { duration: Theme.durSlow }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Weather.icon
            color: Theme.foregroundDim
            font.family: Theme.nerdFontFamily
            font.pixelSize: Theme.iconXs
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(Weather.temperature) + "°C · " + Weather.description
            color: Theme.foregroundDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontM
            font.weight: Theme.weightNormal
          }
        }

        // Distacco tra cosa si legge e cosa si usa.
        Item { width: 1; height: Theme.spacingL }

        SearchField {
          id: field
          width: 320
          icon: Icons.lock
          placeholder: "Password"
          echoMode: TextInput.Password
          enabled: !root.busy
          // Unico elemento interattivo: contorno nel colore del testo, come orologio
          // e data; rosso solo con l'errore.
          ringColor: root.failed ? Theme.urgent : Theme.foreground

          // Translate e non x: la Column non se ne accorge e il layout resta fermo.
          // Tre oscillazioni che si smorzano fino a zero.
          transform: Translate {
            x: Theme.spacingL * Math.sin(root.shakeProgress * Math.PI * 6) * (1 - root.shakeProgress)
          }

          text: root.text
          onTextChanged: root.edited(text)
          onAccepted: root.submitted()
          onCancelled: field.clear()
        }

        // Riga sempre presente anche vuota: il layout non salta quando compare l'errore.
        // Lo spazio di ripiego serve: un Text vuoto e' alto zero e la Column lo salta.
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: root.busy ? "Checking…" : (root.errorText || " ")
          // Rosso: semantica riservata agli errori
          color: root.failed ? Theme.urgent : Theme.foregroundDim
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontS
          font.weight: Theme.weightBold
        }
      }
    }

    TodayCard {
      width: unlockCard.width
      height: unlockCard.height
    }
  }

  // Riavvio e spegnimento: tieni premuto come nella Dashboard, un click per
  // sbaglio sulla schermata di login non deve spegnere il PC.
  Row {
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: Theme.spacingL * 2
    spacing: Theme.spacingM

    IconButton {
      icon: Icons.restart
      holdToConfirm: true
      onActivated: root.rebootRequested()
    }

    IconButton {
      icon: Icons.shutdown
      holdToConfirm: true
      // Azione distruttiva: e' l'unico caso in cui urgent non significa errore.
      hoverColor: Theme.urgent
      onFillColor: Theme.onUrgent
      onActivated: root.shutdownRequested()
    }
  }

  NumberAnimation {
    id: shake
    target: root
    property: "shakeProgress"
    from: 0
    to: 1
    duration: Theme.durSlow * 2
  }

  // lock.qml svuota errorText a ogni tentativo: ogni errore e' un cambio e scuote.
  onErrorTextChanged: if (root.errorText !== "") shake.restart()

  // Disabilitato durante il controllo PAM il campo perde il focus: va ridato.
  onBusyChanged: if (!root.busy) field.forceFocus()
  Component.onCompleted: field.forceFocus()
}
