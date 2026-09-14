// PowerWidget.qml
import QtQuick
import QtQuick.Layouts
import "../../services"

RowLayout {
  id: root
  spacing: Theme.spacingM

  property color fgNormal: Theme.foreground
  property color fgMuted:  Theme.muted

  Text {
    text: Icons.shutdown
    font.family: Theme.nerdFontFamily
    font.pixelSize: Theme.iconXs
    color: root.fgNormal
    horizontalAlignment: Text.AlignHCenter
    Layout.alignment: Qt.AlignVCenter

    Behavior on color {
      ColorAnimation { duration: Theme.durFast }
    }
  }

  HoverHandler {
    cursorShape: Qt.PointingHandCursor
  }

  // Niente TapHandler: il tap lo raccoglie la pill che ci contiene.
}
