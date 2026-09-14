// IconButton.qml
import QtQuick
import "../../services"


Rectangle {
  id: root

  property string icon: ""

  // Il colore dell'hover lo decide chi istanzia: le azioni distruttive
  // usano Theme.urgent, le altre l'accento.
  property color hoverColor: Theme.accent

  signal activated()

  implicitWidth:  48
  implicitHeight: 40

  radius: Theme.radiusS
  antialiasing: true

  color: hover.hovered ? Theme.surfaceHover : Theme.surfaceSolid

  Behavior on color {
    ColorAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
  }

  Text {
    anchors.centerIn: parent
    text: root.icon
    font.family: Theme.nerdFontFamily
    font.pixelSize: Theme.iconM
    color: hover.hovered ? root.hoverColor : Theme.foreground

    Behavior on color {
      ColorAnimation { duration: Theme.durFast }
    }
  }

  HoverHandler {
    id: hover
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    onTapped: root.activated()
  }
}
