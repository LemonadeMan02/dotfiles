// Pill.qml
import QtQuick
import QtQuick.Layouts
import "../../services"


Rectangle {
  id: root

  default property alias content: layout.data
  property alias spacing: layout.spacing

  property int paddingH: Theme.spacingL
  property int paddingV: Theme.spacingM

  property bool interactive: false
  readonly property bool hovered: hover.hovered

  implicitWidth:  layout.implicitWidth  + paddingH * 2
  implicitHeight: layout.implicitHeight + paddingV * 2

  // Angoli arrotondati ma lati dritti: radius fisso, non height/2.
  radius: Theme.radiusM
  antialiasing: true

  color: (interactive && hovered) ? Theme.surfaceHover : Theme.surface

  Behavior on color {
    ColorAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
  }

  HoverHandler {
    id: hover
    enabled: root.interactive
  }

  RowLayout {
    id: layout
    anchors.centerIn: parent
    spacing: Theme.spacingM
  }
}
