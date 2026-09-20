// AppVolume.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../common"
import "../../services"


ColumnLayout {
  id: root
  spacing: Theme.spacingM

  // Niente app, niente blocco: cosi' il separatore sopra non resta orfano.
  visible: Audio.streams.length > 0

  Repeater {
    model: Audio.streams

    delegate: ColumnLayout {
      id: app
      required property var modelData

      Layout.fillWidth: true
      Layout.leftMargin:  Theme.spacingS
      Layout.rightMargin: Theme.spacingS
      spacing: Theme.spacingXs

      readonly property string iconSource: Audio.iconNameFor(app.modelData)
      readonly property bool muted: Audio.mutedOf(app.modelData)

      RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingM

        // Contenitore a larghezza fissa, come in ListEntry: icone di
        // larghezza diversa disallineerebbero i nomi.
        Item {
          Layout.preferredWidth:  Theme.iconL
          Layout.preferredHeight: Theme.iconL
          Layout.alignment: Qt.AlignVCenter

          // Ripiego: un glifo generico e' meglio di un buco.
          Text {
            anchors.centerIn: parent
            visible: app.iconSource === "" || appIcon.status === Image.Error
            text: Icons.app
            font.family: Theme.nerdFontFamily
            font.pixelSize: Theme.iconM
            color: app.muted ? Theme.muted : Theme.foreground

            Behavior on color {
              ColorAnimation { duration: Theme.durFast }
            }
          }

          IconImage {
            id: appIcon
            anchors.centerIn: parent
            width:  Theme.iconM
            height: Theme.iconM
            visible: app.iconSource !== "" && status !== Image.Error
            source: app.iconSource
            opacity: app.muted ? 0.45 : 1.0

            Behavior on opacity {
              NumberAnimation { duration: Theme.durFast }
            }
          }

          HoverHandler {
            cursorShape: Qt.PointingHandCursor
          }

          // Stessa convenzione del sink: il tap sull'icona e' il mute.
          TapHandler {
            onTapped: Audio.toggleNodeMute(app.modelData)
          }
        }

        // Senza elide un nome lungo spinge fuori la percentuale.
        Text {
          text: Audio.labelFor(app.modelData)
          color: app.muted ? Theme.muted : Theme.foreground
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontM
          font.weight: Theme.weightBold
          elide: Text.ElideRight
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignVCenter

          Behavior on color {
            ColorAnimation { duration: Theme.durFast }
          }
        }

        // Larghezza fissa: senza, la riga respira fra 9, 10 e 100.
        Text {
          text: Audio.percentOf(app.modelData) + "%"
          color: Theme.foregroundDim
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontM
          font.weight: Theme.weightBold
          horizontalAlignment: Text.AlignRight
          Layout.preferredWidth: 44
          Layout.alignment: Qt.AlignVCenter
        }
      }

      // Slider a riga intera: a 340px nome e cursore non ci stanno insieme.
      Slider {
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.spacingXs

        value: Audio.volumeOf(app.modelData)
        onMoved: (v) => Audio.setNodeVolume(app.modelData, v)
      }
    }
  }
}
