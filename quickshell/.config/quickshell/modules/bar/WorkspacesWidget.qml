// WorkspacesWidget.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../services"

RowLayout {
  id: root
  spacing: 4

  // Quanti workspace mostrare sempre, anche se vuoti
  property int count: 8

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
      readonly property bool focused: Hyprland.focusedWorkspace
                                      && Hyprland.focusedWorkspace.id === chip.wsId

      implicitWidth: 22
      implicitHeight: 22
      radius: 6

      color: focused ? Theme.foreground
                     : (populated ? Theme.surface : "transparent")

      Behavior on color {
        ColorAnimation { duration: 120 }
      }

      Text {
        anchors.centerIn: parent
        text: chip.wsId
        font.family: Theme.fontFamily
        font.bold: chip.focused
        font.pixelSize: chip.focused ? 13 : 11
        color: chip.focused ? Theme.background
                            : (chip.populated ? Theme.foreground : Theme.muted)
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch("workspace " + chip.wsId)
      }
    }
  }
}
