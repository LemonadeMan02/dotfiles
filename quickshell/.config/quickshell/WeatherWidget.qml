// WeatherWidget.qml
import QtQuick
import QtQuick.Layouts

RowLayout {
  spacing: 6

  Text {
    text: Weather.icon
    font.family: Theme.nerdFontFamily
    font.pixelSize: 16
    color: Theme.foreground
  }

  Text {
    text: Weather.temperature.toFixed(1) + "°C"
    font.family: Theme.fontFamily
    font.pixelSize: 14
    color: Theme.foreground
  }
}
