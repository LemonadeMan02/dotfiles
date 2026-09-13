// NetworkWidget.qml
import QtQuick
import QtQuick.Layouts
import "../../services"

RowLayout {
  id: root
  spacing: Theme.spacingM

  // Cablati dal contenitore, come nel VolumeWidget.
  property color fgNormal: Theme.foreground
  property color fgMuted:  Theme.muted

  readonly property color fg: Net.connected ? fgNormal : fgMuted

  // Incolla i glifi letterali da nerdfonts.com/cheat-sheet.
  readonly property string iconWired:   "󰈀" // nf-md-ethernet
  readonly property string iconWifi:    "" // nf-md-wifi
  readonly property string iconOffline: "" // nf-md-wifi_off

  readonly property string icon: {
    if (!Net.connected) return iconOffline
    return Net.wired ? iconWired : iconWifi
  }

  Text {
    text: root.icon
    font.family: Theme.nerdFontFamily
    font.pixelSize: Theme.iconXs
    color: root.fg
    horizontalAlignment: Text.AlignHCenter
    Layout.preferredWidth: Theme.iconM
    Layout.alignment: Qt.AlignVCenter

    Behavior on color {
      ColorAnimation { duration: Theme.durFast }
    }
  }

  // Senza elide un SSID lungo spinge la barra fuori schermo.
  Text {
    text: Net.label
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontM
    font.weight: Theme.weightBold
    color: root.fg
    elide: Text.ElideRight
    Layout.maximumWidth: 140
    Layout.alignment: Qt.AlignVCenter

    Behavior on color {
      ColorAnimation { duration: Theme.durFast }
    }
  }
}
