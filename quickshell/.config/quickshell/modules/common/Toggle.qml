// Toggle.qml
import QtQuick
import "../../services"


// Senza stato proprio: mostra checked e segnala il click, decide chi lo istanzia.
Rectangle {
  id: root

  property bool checked: false

  signal toggled()

  implicitWidth:  36
  implicitHeight: 20
  radius: Theme.radiusS
  antialiasing: true
  color: root.checked ? Theme.accent : Theme.surfaceSolid

  Behavior on color {
    ColorAnimation { duration: Theme.durFast }
  }

  // Pomello: stessi angoli smussati delle pill, un filo piu' stretti.
  Rectangle {
    width:  14
    height: 14
    y: 3
    x: root.checked ? root.width - width - 3 : 3
    radius: Theme.radiusS - 2
    antialiasing: true
    color: root.checked ? Theme.onAccent : Theme.foregroundDim

    Behavior on x {
      NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
    }
  }

  HoverHandler {
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    onTapped: root.toggled()
  }
}
