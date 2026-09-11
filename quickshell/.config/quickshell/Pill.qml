// Pill.qml
import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root
  default property alias content: layout.data

  radius: Theme.radius
  color: Theme.background
  implicitWidth: layout.implicitWidth + Theme.padding * 2
  implicitHeight: layout.implicitHeight + Theme.padding

  RowLayout {
    id: layout
    anchors.centerIn: parent
    spacing: 8
  }
}
