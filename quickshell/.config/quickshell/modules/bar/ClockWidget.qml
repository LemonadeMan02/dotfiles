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
    font.bold: true
    font.pixelSize: 16
    Layout.alignment: Qt.AlignHCenter
  }

  Text {
    text: Time.date
    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: 11
    opacity: 0.7
    Layout.alignment: Qt.AlignHCenter
  }
}
