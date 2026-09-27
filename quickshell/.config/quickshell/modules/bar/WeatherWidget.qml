// WeatherWidget.qml
import QtQuick
import QtQuick.Layouts
import "../../services"


RowLayout {
  id: root
  spacing: Theme.spacingM

  // Nascosto finche' non c'e' un dato vero: un sole a 0°C sarebbe un'informazione falsa.
  visible: Weather.ready

  // Chi istanzia decide cosa apre: qui si sa solo che e' stato cliccato.
  signal clicked()

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

  HoverHandler {
    cursorShape: Qt.PointingHandCursor
  }

  // Presa esclusiva alla pressione: il click non arriva anche alla pill, che aprirebbe "today".
  TapHandler {
    gesturePolicy: TapHandler.ReleaseWithinBounds
    onTapped: root.clicked()
  }
}
