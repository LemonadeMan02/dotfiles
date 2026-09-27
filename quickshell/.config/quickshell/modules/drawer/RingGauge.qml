// RingGauge.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "../../services"


// Indicatore ad anello: eccezione voluta alla regola "mai cerchi", vale solo per i grafici.
ColumnLayout {
  id: root
  spacing: Theme.spacingS

  // Riempimento 0..1: fuori scala viene tagliato.
  property real value: 0
  property string text: ""
  property string label: ""

  readonly property int size: Theme.iconL * 2
  readonly property int thickness: Theme.spacingS
  readonly property real arcRadius: (root.size - root.thickness) / 2

  Behavior on value {
    NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutCubic }
  }

  Item {
    Layout.alignment: Qt.AlignHCenter
    implicitWidth: root.size
    implicitHeight: root.size

    Shape {
      anchors.fill: parent
      // Curve renderer: bordi lisci senza multisampling sulla finestra.
      preferredRendererType: Shape.CurveRenderer

      // Binario: l'anello intero, in tono spento.
      ShapePath {
        strokeColor: Theme.surfaceSolid
        strokeWidth: root.thickness
        fillColor: "transparent"

        PathAngleArc {
          centerX: root.size / 2
          centerY: root.size / 2
          radiusX: root.arcRadius
          radiusY: root.arcRadius
          startAngle: 0
          sweepAngle: 360
        }
      }

      // Valore: parte da mezzogiorno e gira in senso orario.
      ShapePath {
        strokeColor: Theme.accent
        strokeWidth: root.thickness
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap

        PathAngleArc {
          centerX: root.size / 2
          centerY: root.size / 2
          radiusX: root.arcRadius
          radiusY: root.arcRadius
          startAngle: -90
          sweepAngle: 360 * Math.max(0, Math.min(1, root.value))
        }
      }
    }

    Text {
      anchors.centerIn: parent
      text: root.text
      color: Theme.foreground
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontS
      font.weight: Theme.weightBold
    }
  }

  Text {
    Layout.alignment: Qt.AlignHCenter
    text: root.label
    color: Theme.muted
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontXs
    font.weight: Theme.weightBold
    font.capitalization: Font.AllUppercase
  }
}
