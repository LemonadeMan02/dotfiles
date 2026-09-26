// NotificationPopups.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../../services"


PanelWindow {
  id: root

  // Il primario e' quello in 0x0, come in hypr/monitors.lua: niente nomi di modello duplicati.
  screen: {
    for (const s of Quickshell.screens)
      if (s.x === 0 && s.y === 0) return s
    return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
  }

  // Oltre questo numero la colonna scende troppo: le piu' vecchie aspettano il loro turno.
  readonly property int maxShown: 4
  readonly property int cardWidth: 380

  // Dashboard aperta sullo stesso schermo: stesso angolo, i popup si fanno da parte e aspettano.
  readonly property bool paused: Drawers.isOpen("dashboard") && Drawers.screen === root.screen

  WlrLayershell.namespace: "quickshell:notifications"
  WlrLayershell.layer: WlrLayer.Overlay

  // Zero: la finestra rispetta la zona esclusiva della barra e nasce sotto di lei.
  exclusiveZone: 0
  color: "transparent"

  // Allineato alla dashboard: stesso angolo, stessi margini.
  anchors.top: true
  anchors.right: true
  margins.top: 6
  margins.right: 10

  implicitWidth:  root.cardWidth
  implicitHeight: column.implicitHeight

  // Senza notifiche la superficie non esiste: niente rettangolo invisibile che ruba i click.
  visible: popupModel.values.length > 0 && !root.paused

  // Diff invece di ricreazione: le card gia' a schermo tengono il loro timer.
  ScriptModel {
    id: popupModel
    values: Notifications.list.slice(-root.maxShown).reverse()
  }

  ColumnLayout {
    id: column
    width: root.cardWidth
    spacing: Theme.spacingM

    Repeater {
      model: popupModel

      delegate: Rectangle {
        id: card
        required property var modelData

        readonly property string iconSource: Notifications.iconFor(card.modelData)

        Layout.fillWidth: true
        implicitHeight: row.implicitHeight + Theme.spacingL * 2

        radius: Theme.radiusM
        antialiasing: true
        color: Theme.surface
        border.width: 1
        border.color: Theme.border

        // Entrata in dissolvenza: parte da 0 e il Behavior porta a 1.
        opacity: 0
        Component.onCompleted: card.opacity = 1

        Behavior on opacity {
          NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutCubic }
        }

        // Fermo col mouse sopra o con la dashboard aperta: si legge con calma.
        Timer {
          interval: Notifications.timeoutFor(card.modelData)
          running: !root.paused && !hover.hovered
          onTriggered: card.modelData.expire()
        }

        RowLayout {
          id: row
          anchors.fill: parent
          anchors.margins: Theme.spacingL
          spacing: Theme.spacingL

          // Contenitore a dimensione fissa: icone e glifo occupano lo stesso spazio.
          Item {
            Layout.preferredWidth:  Theme.iconL
            Layout.preferredHeight: Theme.iconL
            Layout.alignment: Qt.AlignTop

            IconImage {
              id: appIcon
              anchors.fill: parent
              visible: card.iconSource !== "" && status !== Image.Error
              source: card.iconSource
            }

            // Ripiego: un glifo generico e' meglio di un buco.
            Text {
              anchors.centerIn: parent
              visible: !appIcon.visible
              text: Icons.app
              font.family: Theme.nerdFontFamily
              font.pixelSize: Theme.iconM
              color: Theme.foregroundDim
            }
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Text {
              visible: text !== ""
              text: card.modelData.appName
              color: Theme.foregroundDim
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontXs
              font.weight: Theme.weightNormal
              elide: Text.ElideRight
              Layout.fillWidth: true
            }

            Text {
              text: card.modelData.summary
              color: Theme.foreground
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontM
              font.weight: Theme.weightBold
              textFormat: Text.PlainText
              wrapMode: Text.Wrap
              maximumLineCount: 2
              elide: Text.ElideRight
              Layout.fillWidth: true
            }

            // Testo semplice finche' il markup non ha la sua gestione: niente tag mostrati a meta'.
            Text {
              visible: text !== ""
              text: card.modelData.body
              color: Theme.foreground
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontS
              font.weight: Theme.weightNormal
              textFormat: Text.PlainText
              wrapMode: Text.Wrap
              maximumLineCount: 4
              elide: Text.ElideRight
              Layout.fillWidth: true
            }
          }
        }

        HoverHandler {
          id: hover
          cursorShape: Qt.PointingHandCursor
        }

        // Click = chiusa dall'utente: l'app lo viene a sapere, diversamente dalla scadenza.
        TapHandler {
          onTapped: card.modelData.dismiss()
        }
      }
    }
  }
}
