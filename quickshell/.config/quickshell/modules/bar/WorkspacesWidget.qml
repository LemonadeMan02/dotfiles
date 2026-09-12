// WorkspacesWidget.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../services"

RowLayout {
  id: root
  spacing: Theme.spacingS

  required property var screen

  property int count: 8

  property int chipSize: 22
  property int chipSizeFocused: 34
  property int dotSize: 12

  // Assegnata a mano, non via binding: monitorFor() tocca lo stesso modello
  // Hyprland.monitors da cui il binding dipenderebbe, e il risultato e' un loop.
  property HyprlandMonitor monitor: null

  function updateMonitor() {
    root.monitor = Hyprland.monitorFor(root.screen)
  }

  Component.onCompleted: root.updateMonitor()

  Connections {
    target: Hyprland.monitors
    function onValuesChanged() { root.updateMonitor() }
  }

  readonly property var activeWs: monitor ? monitor.activeWorkspace : null
  readonly property bool monitorFocused: monitor ? monitor.focused : false

  function goToWorkspace(id) {
    if (Hyprland.usingLua)
      Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })")
    else
      Hyprland.dispatch("workspace " + id)
  }

  Repeater {
    model: root.count

    delegate: Rectangle {
      id: chip
      required property int index

      readonly property int wsId: index + 1

      readonly property var ws: {
        for (const w of Hyprland.workspaces.values)
          if (w.id === chip.wsId) return w
        return null
      }

      readonly property bool populated: ws !== null
      readonly property bool active: root.activeWs !== null
                                     && root.activeWs.id === chip.wsId
      readonly property bool focused: active && root.monitorFocused
      readonly property bool urgent: ws !== null && ws.urgent

      implicitHeight: root.chipSize
      implicitWidth: focused ? root.chipSizeFocused
                             : (populated || active ? root.chipSize : root.dotSize)

      // Angoli smussati ma lati dritti, come le pill.
      radius: Theme.radiusS
      antialiasing: true

      color: focused   ? Theme.accent
           : urgent    ? Theme.urgent
           : active    ? "transparent"
           : populated ? Theme.surfaceSolid
                       : "transparent"

      border.width: (active && !focused) ? 2 : 0
      border.color: Theme.accent

      scale: hover.hovered ? 1.15 : 1.0

      Behavior on implicitWidth {
        NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutBack }
      }
      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }
      Behavior on scale {
        NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
      }

      Text {
        anchors.centerIn: parent
        visible: chip.populated || chip.active
        text: chip.wsId
        font.family: Theme.fontFamily
        font.weight: Theme.weightBold
        font.pixelSize: chip.focused ? Theme.fontS : Theme.fontXs
        color: (chip.focused || chip.urgent) ? Theme.onAccent : Theme.foreground
      }

      Rectangle {
        anchors.centerIn: parent
        visible: !chip.populated && !chip.active
        implicitWidth: 5
        implicitHeight: 5
        radius: 2.5
        color: Theme.muted
      }

      HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        onTapped: root.goToWorkspace(chip.wsId)
      }
    }
  }
}
