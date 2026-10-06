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

  // Scheda centrale: stessa superficie delle pill, il testo segue il tema.
  Rectangle {
    anchors.centerIn: parent
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

      // Distacco tra cosa si legge e cosa si usa.
      Item { width: 1; height: Theme.spacingL }

      SearchField {
        id: field
        width: 320
        icon: Icons.lock
        placeholder: "Password"
        echoMode: TextInput.Password
        enabled: !root.busy

        text: root.text
        onTextChanged: root.edited(text)
        onAccepted: root.submitted()
        onCancelled: field.clear()
      }

      // Riga sempre presente anche vuota: il layout non salta quando compare l'errore.
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.busy ? "Checking…" : root.errorText
        // Rosso: semantica riservata agli errori
        color: root.errorText !== "" && !root.busy ? Theme.urgent : Theme.foregroundDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontS
        font.weight: Theme.weightBold
      }
    }
  }

  // Disabilitato durante il controllo PAM il campo perde il focus: va ridato.
  onBusyChanged: if (!root.busy) field.forceFocus()
  Component.onCompleted: field.forceFocus()
}
