// ListEntry.qml
import QtQuick
import QtQuick.Layouts
import "../../services"


Rectangle {
  id: root

  property string icon: ""
  property string title: ""
  property string subtitle: ""

  // La riga non sa cosa fa: lo decide chi la istanzia.
  signal activated()

  implicitWidth:  row.implicitWidth  + Theme.spacingL * 2
  implicitHeight: row.implicitHeight + Theme.spacingM * 2

  radius: Theme.radiusS
  antialiasing: true

  // Trasparente a riposo: il fondo e' gia' la superficie del drawer.
  color: hover.hovered ? Theme.surfaceHover : "transparent"

  Behavior on color {
    ColorAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
  }

  RowLayout {
    id: row
    anchors.fill: parent
    anchors.leftMargin:  Theme.spacingL
    anchors.rightMargin: Theme.spacingL
    spacing: Theme.spacingL

    Text {
      text: root.icon
      font.family: Theme.nerdFontFamily
      font.pixelSize: Theme.iconM
      color: hover.hovered ? Theme.accent : Theme.foreground
      horizontalAlignment: Text.AlignHCenter
      // Larghezza fissa: senza, glifi di larghezza diversa disallineano i titoli.
      Layout.preferredWidth: Theme.iconL
      Layout.alignment: Qt.AlignVCenter

      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }
    }

    ColumnLayout {
      spacing: 0
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter

      Text {
        text: root.title
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontM
        font.weight: Theme.weightBold
        elide: Text.ElideRight
        Layout.fillWidth: true
      }

      Text {
        text: root.subtitle
        visible: root.subtitle !== ""
        color: Theme.foregroundDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontXs
        font.weight: Theme.weightNormal
        elide: Text.ElideRight
        Layout.fillWidth: true
      }
    }
  }

  HoverHandler {
    id: hover
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    onTapped: root.activated()
  }
}
