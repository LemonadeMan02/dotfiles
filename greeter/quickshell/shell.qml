// shell.qml del greeter: una finestra per schermo, login solo su quello principale
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Greetd
import QtQuick
import "services"


ShellRoot {
  id: root

  // Output con orologio e password; gli altri mostrano solo lo sfondo
  readonly property string mainScreen: "DP-1"

  // Fuori da greetd siamo in prova: tastiera non esclusiva, Esc chiude
  readonly property bool testMode: !Greetd.available

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: win

      required property var modelData
      readonly property bool isMain: modelData.name === root.mainScreen

      screen: modelData
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      color: Theme.background

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "greeter"
      // Exclusive solo sotto greetd: in prova un bug non ti blocca la tastiera
      WlrLayershell.keyboardFocus: !win.isMain ? WlrKeyboardFocus.None
                                 : root.testMode ? WlrKeyboardFocus.OnDemand
                                 : WlrKeyboardFocus.Exclusive

      Column {
        visible: win.isMain
        anchors.centerIn: parent
        spacing: Theme.spacingM

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: Qt.formatDateTime(clock.date, "HH:mm")
          color: Theme.foreground
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontClock
          font.weight: Theme.weightBold
        }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
          color: Theme.foregroundDim
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontDate
          font.weight: Theme.weightNormal
        }

        // Stacco fra data e campo, come i position di hyprlock
        Item { width: 1; height: Theme.spacingL * 4 }

        Rectangle {
          id: field
          anchors.horizontalCenter: parent.horizontalCenter
          width: Theme.fieldWidth
          height: Theme.fieldHeight
          radius: Theme.radiusM
          color: Theme.surface
          border.width: Theme.fieldBorder
          border.color: Theme.accent

          TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingL
            anchors.rightMargin: Theme.spacingL
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            echoMode: TextInput.Password
            passwordCharacter: "•"
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontM
            font.weight: Theme.weightBold
            clip: true
            focus: true

            // Niente cursore, come hyprlock: i pallini bastano a dare riscontro
            cursorDelegate: Item {}

            Component.onCompleted: forceActiveFocus()

            // Via d'uscita della modalita' prova
            Keys.onEscapePressed: if (root.testMode) Qt.quit()

            // Segnaposto: l'autenticazione arriva al passo successivo
            onAccepted: {
              console.log("greeter: invio ricevuto (prova)")
              input.text = ""
            }
          }

          Text {
            anchors.centerIn: parent
            visible: input.length === 0
            text: "Password"
            color: Theme.foregroundDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontM
            font.weight: Theme.weightNormal
          }
        }
      }
    }
  }
}
