// HourOrbit.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "../../services"


// Ore disposte su un'ellisse vista in prospettiva: davanti grandi e piene, dietro piccole e tenui.
// Il contenuto dichiarato dentro (l'orologio) sta al centro, fra le schede dietro e quelle davanti.
Item {
  id: root

  // [{ time, temp, icon }] da Weather.hoursFor(); la prima va davanti, al centro.
  property var hours: []
  // Oggi la prima e' l'ora corrente: evidenziata. Gli altri giorni no.
  property bool highlightFirst: false

  default property alias content: center.data

  // Scheda a riposo; davanti viene ingrandita, dietro rimpicciolita.
  readonly property int cardW: Theme.chipHeight * 3 / 2
  readonly property int cardH: Theme.chipHeight * 5 / 2
  readonly property real minScale: 0.7
  readonly property real maxScale: 1.05

  // Semiassi: il verticale fissa l'altezza, l'orizzontale segue la larghezza disponibile.
  readonly property real ry: Theme.chipHeight * 7 / 2
  readonly property real rx: Math.max(ry, (width - cardW * maxScale) / 2)

  implicitHeight: ry * 2 + cardH * maxScale + Theme.spacingL * 2

  // Gradi aggiunti a tutte le schede: a ogni cambio di ore l'orbita arriva ruotando.
  property real turn: 0

  onHoursChanged: spin.restart()

  NumberAnimation {
    id: spin
    target: root
    property: "turn"
    from: 360 / Math.max(1, root.hours.length)
    to: 0
    duration: Theme.durSlow * 3
    easing.type: Easing.OutCubic
  }

  // Traccia tratteggiata dell'orbita: fa parte dell'eccezione dei grafici.
  Shape {
    anchors.fill: parent
    z: -1
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      strokeColor: Theme.border
      strokeWidth: 1
      strokeStyle: ShapePath.DashLine
      dashPattern: [3, 5]
      fillColor: "transparent"

      PathAngleArc {
        centerX: root.width / 2
        centerY: root.height / 2
        radiusX: root.rx
        radiusY: root.ry
        startAngle: 0
        sweepAngle: 360
      }
    }
  }

  // z 0.5: dietro le schede anteriori (z > 0.5), davanti a quelle posteriori.
  Item {
    id: center
    anchors.centerIn: parent
    width: childrenRect.width
    height: childrenRect.height
    z: 0.5
  }

  Repeater {
    model: root.hours

    delegate: Rectangle {
      id: card
      required property var modelData
      required property int index

      // 90 gradi = in basso, cioe' davanti; le successive in senso orario.
      readonly property real angle: (90 + card.index * 360 / root.hours.length + root.turn) * Math.PI / 180
      // 0 = in fondo all'orbita, 1 = davanti.
      readonly property real depth: (Math.sin(card.angle) + 1) / 2
      readonly property bool current: root.highlightFirst && card.index === 0

      width: root.cardW
      height: root.cardH
      x: root.width / 2 + Math.cos(card.angle) * root.rx - width / 2
      y: root.height / 2 + Math.sin(card.angle) * root.ry - height / 2
      z: card.depth
      scale: root.minScale + (root.maxScale - root.minScale) * card.depth
      opacity: 0.45 + 0.55 * card.depth

      radius: Theme.radiusS
      antialiasing: true
      color: card.current ? Theme.surfaceLight : Theme.surfaceSolid

      ColumnLayout {
        anchors.centerIn: parent
        spacing: Theme.spacingXs

        Text {
          Layout.alignment: Qt.AlignHCenter
          text: card.modelData.time
          color: card.current ? Theme.onLight : Theme.foregroundDim
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontXs
          font.weight: Theme.weightBold
        }

        Text {
          Layout.alignment: Qt.AlignHCenter
          text: card.modelData.icon
          color: card.current ? Theme.onLight : Theme.foreground
          font.family: Theme.nerdFontFamily
          font.pixelSize: Theme.iconM
        }

        Text {
          Layout.alignment: Qt.AlignHCenter
          text: Math.round(card.modelData.temp) + "°"
          color: card.current ? Theme.onLight : Theme.foreground
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontS
          font.weight: Theme.weightBold
        }
      }
    }
  }
}
