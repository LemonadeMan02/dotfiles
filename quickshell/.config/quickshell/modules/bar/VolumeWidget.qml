// VolumeWidget.qml
import QtQuick
import QtQuick.Layouts
import "../../services"

RowLayout {
  id: root
  spacing: Theme.spacingM

  // Incolla i glifi letterali da nerdfonts.com/cheat-sheet.
  readonly property string iconMuted:  "" // nf-md-volume_off
  readonly property string iconLow:    "" // nf-md-volume_low
  readonly property string iconMedium: "" // nf-md-volume_medium
  readonly property string iconHigh:   "" // nf-md-volume_high

  readonly property string icon: {
    if (Audio.muted || Audio.volume <= 0) return iconMuted
    if (Audio.volume < 0.34) return iconLow
    if (Audio.volume < 0.67) return iconMedium
    return iconHigh
  }

  readonly property color fg: Audio.muted ? Theme.muted : Theme.foreground

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

  TapHandler {
    onTapped: Audio.toggleMute()
  }

  WheelHandler {
    onWheel: (event) => Audio.stepVolume(event.angleDelta.y > 0 ? 0.05 : -0.05)
  }
}
