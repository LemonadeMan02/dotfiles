// KeyboardWidget.qml
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
    text: Icons.keyboard
    font.family: Theme.nerdFontFamily
    font.pixelSize: Theme.iconXs
    color: root.fgMuted
    horizontalAlignment: Text.AlignHCenter
    Layout.preferredWidth: Theme.iconM
    Layout.alignment: Qt.AlignVCenter
  }

  Text {
    text: Kb.code
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontM
    font.weight: Theme.weightBold
    color: root.fgNormal
    Layout.alignment: Qt.AlignVCenter
  }
}
