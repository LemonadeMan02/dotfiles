// VolumeWidget.qml
import QtQuick
import QtQuick.Layouts
import "../../services"

RowLayout {
  id: root
  spacing: Theme.spacingM

  // Chi ospita il widget decide i colori. Qui ci sono solo i default,
  // validi se il widget finisce su una pill scura.
  property color fgNormal: Theme.foreground
  property color fgMuted:  Theme.muted

  readonly property color fg: Audio.muted ? fgMuted : fgNormal

  Text {
    text: Audio.icon
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

  // Larghezza fissa: senza, la pill respira a ogni passaggio fra 9, 10 e 100.
  Text {
    text: Audio.percent + "%"
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontM
    font.weight: Theme.weightBold
    color: root.fg
    horizontalAlignment: Text.AlignRight
    Layout.preferredWidth: 44
    Layout.alignment: Qt.AlignVCenter

    Behavior on color {
      ColorAnimation { duration: Theme.durFast }
    }
  }

  HoverHandler {
    cursorShape: Qt.PointingHandCursor
  }

  // Niente TapHandler: il click sulla pill apre il dashboard, e il mute
  // vive li' dentro. Lo scroll non collide e resta la scorciatoia veloce.
  WheelHandler {
    onWheel: (event) => Audio.stepVolume(event.angleDelta.y > 0 ? 0.05 : -0.05)
  }
}
