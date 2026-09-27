// TrayWidget.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../services"

RowLayout {
  id: root
  spacing: Theme.spacingXs

  // Finestra della barra: display() vuole coordinate relative a lei.
  required property var window

  readonly property int count: SystemTray.items.values.length

  Repeater {
    model: SystemTray.items

    delegate: Rectangle {
      id: slot
      required property SystemTrayItem modelData

      implicitWidth:  Theme.chipHeight
      implicitHeight: Theme.chipHeight

      // Stesso velo dei workspace: contrasta con qualunque palette.
      radius: Theme.radiusS
      antialiasing: true
      color: hover.hovered ? Theme.withAlpha(Theme.foreground, 0.14) : "transparent"

      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }

      IconImage {
        anchors.centerIn: parent
        implicitSize: Theme.iconM
        source: slot.modelData.icon
      }

      // Menu sotto l'icona: la barra sta in alto.
      function openMenu() {
        const p = slot.mapToItem(null, 0, slot.height + Theme.spacingS)
        slot.modelData.display(root.window, p.x, p.y)
      }

      HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onTapped: (eventPoint, button) => {
          const item = slot.modelData
          if (button === Qt.RightButton || (button === Qt.LeftButton && item.onlyMenu)) {
            if (item.hasMenu) slot.openMenu()
          } else if (button === Qt.MiddleButton) {
            item.secondaryActivate()
          } else {
            item.activate()
          }
        }
      }
    }
  }
}
