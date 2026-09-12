// WeatherWidget.qml
import QtQuick
import QtQuick.Layouts
import "../../services"


RowLayout {
  spacing: Theme.spacingS

  Text {
    text: Weather.icon
    font.family: Theme.nerdFontFamily
    font.pixelSize: Theme.iconM
    color: Theme.foreground
  }

  Text {
    text: Math.round(Weather.temperature) + "°C"
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontM
    font.weight: Theme.weightBold
    color: Theme.foreground
  }
}
