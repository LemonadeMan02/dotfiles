// Drawer.qml
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
  implicitWidth:  layout.implicitWidth  + 40
  implicitHeight: layout.implicitHeight + 30

  Component.onCompleted: {
    console.log("Drawer: creato su", root.screen ? root.screen.name : "?",
                root.implicitWidth + "x" + root.implicitHeight)
    Drawers.registerWindow(root)
  }

  Rectangle {
    anchors.fill: parent

    radius: Theme.radiusM
    color: Theme.surface
    antialiasing: true

    Behavior on color {
      ColorAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
    }

    HoverHandler {
      onHoveredChanged: Drawers.hovered = hovered
    }
  }

  ColumnLayout {
    id: layout
    anchors.centerIn: parent
    spacing: Theme.spacingS

    Text {
      text: "Drawer"
      color: Theme.foreground
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontL
      font.weight: Theme.weightBold
      Layout.alignment: Qt.AlignHCenter
    }

    Text {
      text: root.screen ? root.screen.name : "?"
      color: Theme.foregroundDim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontXs
      font.weight: Theme.weightNormal
      Layout.alignment: Qt.AlignHCenter
    }
  }
}
