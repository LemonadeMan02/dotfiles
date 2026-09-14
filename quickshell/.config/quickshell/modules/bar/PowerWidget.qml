// PowerWidget.qml
import QtQuick
import QtQuick.Layouts
import "../../services"

RowLayout {
  id: root
  spacing: Theme.spacingM

  // Incolla il glifo letterale nf-md-power da nerdfonts.com/cheat-sheet:
  // questo e' un carattere Unicode generico, non un glifo della Nerd Font.
  readonly property string iconPower: "⏻"

  property color fgNormal: Theme.foreground
  property color fgMuted:  Theme.muted

  Text {
    text: root.iconPower
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
