// DrawerWindow.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../services"

PanelWindow {
  id: root

  screen: Drawers.screen

  WlrLayershell.namespace: "quickshell:drawer"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

  exclusiveZone: 0
  color: "transparent"

  anchors.bottom: true
  margins.bottom: 10

  // La finestra si misura sul layout, non sul Rectangle: il Rectangle ha
  // anchors.fill e prenderebbe la taglia dalla finestra, chiudendo il giro.
  // Il minimo evita che il pannello si stringa su titoli corti.
  implicitWidth:  Math.max(400, layout.implicitWidth + Theme.spacingM * 2)
  implicitHeight: layout.implicitHeight + Theme.spacingM * 2

  Component.onCompleted: Drawers.registerWindow(root)

  // L'hover sta qui e non sul Rectangle: ora dentro ci sono righe con i
  // loro HoverHandler, e l'auto-close non deve dipendere da chi vince.
  Item {
    anchors.fill: parent

    HoverHandler {
      onHoveredChanged: Drawers.hovered = hovered
    }

    Rectangle {
      anchors.fill: parent

      radius: Theme.radiusM
      color: Theme.surface
      antialiasing: true

      Behavior on color {
        ColorAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
      }
    }

    ColumnLayout {
      id: layout
      anchors.fill: parent
      anchors.margins: Theme.spacingM
      spacing: Theme.spacingXs

      QuickSettings {
        Layout.fillWidth: true
      }
    }
  }
}
