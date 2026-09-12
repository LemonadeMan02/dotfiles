// ClockWidget.qml
import QtQuick
import QtQuick.Layouts
import "../../services"

ColumnLayout {
  spacing: 0

  Text {
    text: Time.time
    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontL
    font.weight: Theme.weightBold
    Layout.alignment: Qt.AlignHCenter
  }

  Text {
    text: Time.date
    // Prima era opacity: 0.7. Un colore dedicato e' meglio: l'opacity
    // agisce sul rendering dell'item, il token e' una scelta di design.
    color: Theme.foregroundDim
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontXs
    font.weight: Theme.weightNormal
    Layout.alignment: Qt.AlignHCenter
  }
}
