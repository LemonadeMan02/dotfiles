// Slider.qml
import QtQuick
import "../../services"


Item {
  id: root

  // 0..1. Lo tiene aggiornato chi ospita lo slider: qui non si scrive mai.
  property real value: 0
  property real step: 0.05

  // Unico canale d'uscita. Il valore lo cambia il chiamante, non noi.
  signal moved(real v)

  implicitWidth:  240
  implicitHeight: 18

  readonly property int trackHeight: 6
  readonly property int handleSize:  14

  function emitFor(x) {
    root.moved(Math.max(0, Math.min(1, x / root.width)))
  }

  Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width
    height: root.trackHeight
    radius: height / 2
    color: Theme.surfaceSolid
    antialiasing: true

    Rectangle {
      width: parent.width * root.value
      height: parent.height
      radius: parent.radius
      color: Theme.accent
      antialiasing: true
    }
  }

  Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    width:  root.handleSize
    height: root.handleSize
    radius: Theme.radiusS
    color: Theme.accent
    antialiasing: true

    // Il clamp evita che la maniglia sbordi dal pannello agli estremi.
    x: Math.max(0, Math.min(root.width - width,
                            root.width * root.value - width / 2))

    scale: (hover.hovered || drag.active) ? 1.2 : 1.0

    Behavior on scale {
      NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
    }
  }

  HoverHandler {
    id: hover
    cursorShape: Qt.PointingHandCursor
  }

  // target: null -> la maniglia non si sposta da sola. La sua x resta una
  // funzione di value, e non nasce nessun binding a due sensi da rompere.
  DragHandler {
    id: drag
    target: null
    xAxis.enabled: true
    yAxis.enabled: false
    onCentroidChanged: if (active) root.emitFor(centroid.position.x)
  }

  TapHandler {
    onTapped: (point) => root.emitFor(point.position.x)
  }

  WheelHandler {
    onWheel: (event) => root.moved(Math.max(0, Math.min(1,
               root.value + (event.angleDelta.y > 0 ? root.step : -root.step))))
  }
}
