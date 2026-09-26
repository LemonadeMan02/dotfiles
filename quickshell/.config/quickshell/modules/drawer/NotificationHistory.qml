// NotificationHistory.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../../services"


// Sempre visibile: con la cronologia vuota l'interruttore deve restare raggiungibile.
ColumnLayout {
  id: root
  spacing: Theme.spacingXs

  // Oltre, la dashboard diventerebbe piu' alta dello schermo.
  readonly property int maxShown: 6
  readonly property int visualSize: 28

  readonly property int count: Notifications.history.length

  // Diff invece di ricreazione: chiudere una voce non ricostruisce le altre.
  ScriptModel {
    id: historyModel
    values: Notifications.history.slice(-root.maxShown).reverse()
  }

  // Intestazione: titolo, conteggio, non disturbare.
  RowLayout {
    Layout.fillWidth: true
    Layout.leftMargin:  Theme.spacingS
    Layout.rightMargin: Theme.spacingS
    Layout.bottomMargin: Theme.spacingXs
    spacing: Theme.spacingS

    Text {
      text: "Notifications"
      color: Theme.foreground
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontM
      font.weight: Theme.weightBold
    }

    Text {
      visible: root.count > 0
      text: root.count
      color: Theme.foregroundDim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontS
      font.weight: Theme.weightBold
    }

    Item { Layout.fillWidth: true }

    Text {
      text: "Do not disturb"
      color: Notifications.dnd ? Theme.foreground : Theme.foregroundDim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontS
      font.weight: Theme.weightNormal
      Layout.alignment: Qt.AlignVCenter
    }

    // Interruttore: carrello e pomello, stessi angoli smussati delle pill.
    Rectangle {
      id: dndSwitch
      readonly property bool on: Notifications.dnd

      implicitWidth:  36
      implicitHeight: 20
      radius: Theme.radiusS
      antialiasing: true
      color: dndSwitch.on ? Theme.accent : Theme.surfaceSolid
      Layout.alignment: Qt.AlignVCenter

      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }

      Rectangle {
        width:  14
        height: 14
        y: 3
        x: dndSwitch.on ? dndSwitch.width - width - 3 : 3
        radius: Theme.radiusS - 2
        antialiasing: true
        color: dndSwitch.on ? Theme.onAccent : Theme.foregroundDim

        Behavior on x {
          NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
        }
      }

      HoverHandler {
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        onTapped: {
          Drawers.poke()
          Config.toggleDnd()
        }
      }
    }
  }

  Text {
    visible: root.count === 0
    text: "No notifications"
    color: Theme.muted
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontS
    font.weight: Theme.weightNormal
    Layout.leftMargin: Theme.spacingS
    Layout.bottomMargin: Theme.spacingXs
  }

  Repeater {
    model: historyModel

    delegate: Rectangle {
      id: entry
      required property var modelData

      readonly property string visual: Notifications.visualFor(entry.modelData)

      Layout.fillWidth: true
      implicitHeight: row.implicitHeight + Theme.spacingM * 2

      radius: Theme.radiusS
      antialiasing: true

      // Trasparente a riposo, come le righe del launcher: il fondo e' gia' il cassetto.
      color: hover.hovered ? Theme.surfaceHover : "transparent"

      Behavior on color {
        ColorAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
      }

      RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin:  Theme.spacingS
        anchors.rightMargin: Theme.spacingS
        spacing: Theme.spacingM

        ClippingRectangle {
          Layout.preferredWidth:  root.visualSize
          Layout.preferredHeight: root.visualSize
          Layout.alignment: Qt.AlignTop
          radius: Theme.radiusS
          color: "transparent"

          Image {
            id: visualImage
            anchors.fill: parent
            visible: entry.visual !== "" && status !== Image.Error
            source: entry.visual
            fillMode: Image.PreserveAspectCrop
            sourceSize.width:  root.visualSize * 2
            sourceSize.height: root.visualSize * 2
            asynchronous: true
          }

          // Ripiego: un glifo generico e' meglio di un buco.
          Text {
            anchors.centerIn: parent
            visible: !visualImage.visible
            text: Icons.app
            font.family: Theme.nerdFontFamily
            font.pixelSize: Theme.fontL
            color: Theme.foregroundDim
          }
        }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 0

          Text {
            text: entry.modelData.appName
            color: Theme.foregroundDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontXs
            font.weight: Theme.weightNormal
            elide: Text.ElideRight
            Layout.fillWidth: true
          }

          Text {
            text: entry.modelData.summary
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontS
            font.weight: Theme.weightBold
            textFormat: Text.PlainText
            elide: Text.ElideRight
            Layout.fillWidth: true
          }

          Text {
            visible: text !== ""
            text: entry.modelData.body
            color: Theme.foregroundDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontXs
            font.weight: Theme.weightNormal
            textFormat: Text.PlainText
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            Layout.fillWidth: true
          }
        }

        // Chiude la voce senza eseguire l'azione di default.
        Text {
          text: "×"
          color: closeHover.hovered ? Theme.foreground : Theme.foregroundDim
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontL
          font.weight: Theme.weightBold
          Layout.alignment: Qt.AlignTop

          HoverHandler {
            id: closeHover
            cursorShape: Qt.PointingHandCursor
          }

          // Presa esclusiva alla pressione: il click non arriva anche alla voce sotto.
          TapHandler {
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: {
              Drawers.poke()
              entry.modelData.dismiss()
            }
          }
        }
      }

      HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
      }

      // Con un'azione di default l'app si apre: chiudi prima, il focus grab se la mangerebbe.
      TapHandler {
        onTapped: {
          if (Notifications.defaultAction(entry.modelData)) Drawers.close()
          else Drawers.poke()
          Notifications.activate(entry.modelData)
        }
      }
    }
  }

  // Piede: quante ne restano fuori e pulizia.
  RowLayout {
    visible: root.count > 0
    Layout.fillWidth: true
    Layout.leftMargin:  Theme.spacingS
    Layout.rightMargin: Theme.spacingS
    Layout.topMargin:   Theme.spacingXs
    spacing: Theme.spacingS

    Text {
      text: root.count > root.maxShown ? "+" + (root.count - root.maxShown) + " more" : ""
      color: Theme.muted
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontXs
      font.weight: Theme.weightNormal
      Layout.fillWidth: true
    }

    Text {
      text: "Clear all"
      color: clearHover.hovered ? Theme.accent : Theme.foregroundDim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontS
      font.weight: Theme.weightBold

      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }

      HoverHandler {
        id: clearHover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        onTapped: {
          Drawers.poke()
          Notifications.clearAll()
        }
      }
    }
  }
}
