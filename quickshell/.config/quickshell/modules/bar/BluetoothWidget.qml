// BluetoothWidget.qml
import QtQuick
import QtQuick.Layouts
import "../../services"

RowLayout {
  id: root
  spacing: Theme.spacingM

  // Cablati dal contenitore, come negli altri widget.
  property color fgNormal: Theme.foreground
  property color fgMuted:  Theme.muted

  Text {
    text: Icons.headphones
    font.family: Theme.nerdFontFamily
    font.pixelSize: Theme.iconXs
    color: root.fgNormal
    horizontalAlignment: Text.AlignHCenter
    Layout.preferredWidth: Theme.iconM
    Layout.alignment: Qt.AlignVCenter
  }

  // Senza elide un nome lungo spinge la barra fuori schermo.
  Text {
    text: Bt.name
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontM
    font.weight: Theme.weightBold
    color: root.fgNormal
    elide: Text.ElideRight
    Layout.maximumWidth: 120
    Layout.alignment: Qt.AlignVCenter
  }

  // Larghezza fissa come nel volume: il chip non respira fra 9% e 100%.
  Text {
    visible: Bt.hasBattery
    text: Bt.battery + "%"
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontM
    font.weight: Theme.weightBold
    color: root.fgMuted
    horizontalAlignment: Text.AlignRight
    Layout.preferredWidth: 44
    Layout.alignment: Qt.AlignVCenter
  }
}
