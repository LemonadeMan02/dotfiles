// WeatherWidget.qml
import QtQuick
import QtQuick.Layouts
import "../../services"


RowLayout {
  spacing: Theme.spacingM

  // Nascosto finche' non c'e' un dato vero: un sole a 0°C sarebbe un'informazione falsa.
  visible: Weather.ready

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
