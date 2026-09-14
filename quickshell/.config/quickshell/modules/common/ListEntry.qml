// ListEntry.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../../services"


Rectangle {
  id: root

  // Due canali alternativi: un glifo Nerd Font, oppure il nome di
  // un'icona di sistema da risolvere contro il tema installato.
  // iconSource vince se valorizzato.
  property string icon: ""
  property string iconSource: ""

  property string title: ""
  property string subtitle: ""

  // Evidenziazione da tastiera. Separata dall'hover: le frecce e il mouse
  // possono puntare righe diverse e nessuna delle due deve vincere.
  property bool highlighted: false

  readonly property bool active: hover.hovered || root.highlighted

  // La riga non sa cosa fa: lo decide chi la istanzia.
  signal activated()

  implicitWidth:  row.implicitWidth  + Theme.spacingL * 2
  implicitHeight: row.implicitHeight + Theme.spacingM * 2

  radius: Theme.radiusS
  antialiasing: true

  // Trasparente a riposo: il fondo e' gia' la superficie del drawer.
  color: root.active ? Theme.surfaceHover : "transparent"

  Behavior on color {
    ColorAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
  }

  RowLayout {
    id: row
    anchors.fill: parent
    anchors.leftMargin:  Theme.spacingL
    anchors.rightMargin: Theme.spacingL
    spacing: Theme.spacingL

    // Contenitore a larghezza fissa: senza, glifi e icone di larghezza
    // diversa disallineano i titoli da una riga all'altra.
    Item {
      visible: root.icon !== "" || root.iconSource !== ""
      Layout.preferredWidth:  Theme.iconL
      Layout.preferredHeight: Theme.iconL
      Layout.alignment: Qt.AlignVCenter

      Text {
        anchors.centerIn: parent
        // Anche il ripiego dell'icona di sistema: un buco e' peggio di
        // un glifo generico.
        visible: root.iconSource === "" || appIcon.status === Image.Error
        text: root.iconSource !== "" ? Icons.app : root.icon
        font.family: Theme.nerdFontFamily
        font.pixelSize: Theme.iconM
        color: root.active ? Theme.accent : Theme.foreground
        horizontalAlignment: Text.AlignHCenter

        Behavior on color {
          ColorAnimation { duration: Theme.durFast }
        }
      }

      IconImage {
        id: appIcon
        anchors.centerIn: parent
        width:  Theme.iconM
        height: Theme.iconM
        visible: root.iconSource !== "" && status !== Image.Error
        source: root.iconSource
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
