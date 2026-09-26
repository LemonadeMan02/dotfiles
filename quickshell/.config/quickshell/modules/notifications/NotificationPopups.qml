// NotificationPopups.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Notifications
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
  readonly property int visualSize: 40

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

        readonly property bool critical: card.modelData.urgency === NotificationUrgency.Critical
        readonly property string visual: Notifications.visualFor(card.modelData)
        readonly property string badge: Notifications.badgeFor(card.modelData)
        readonly property var buttons: Notifications.buttonsFor(card.modelData)
        readonly property int timeout: Notifications.timeoutFor(card.modelData)

        Layout.fillWidth: true
        implicitHeight: row.implicitHeight + Theme.spacingL * 2

        radius: Theme.radiusM
        antialiasing: true
        color: Theme.surface

        // Le critiche si riconoscono dal bordo: restano finche' non le chiudi.
        border.width: card.critical ? 2 : 1
        border.color: card.critical ? Theme.urgent : Theme.border

        // Entrata in dissolvenza: parte da 0 e il Behavior porta a 1.
        opacity: 0
        Component.onCompleted: card.opacity = 1

        Behavior on opacity {
          NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutCubic }
        }

        // Fermo col mouse sopra o con la dashboard aperta; timeout 0 = nessuna scadenza.
        Timer {
          interval: Math.max(1, card.timeout)
          running: card.timeout > 0 && !root.paused && !hover.hovered
          onTriggered: card.modelData.expire()
        }

        RowLayout {
          id: row
          anchors.fill: parent
          anchors.margins: Theme.spacingL
          spacing: Theme.spacingL

          // Immagine o icona a sinistra; il ritaglio arrotonda anche gli avatar quadrati.
          ClippingRectangle {
            Layout.preferredWidth:  root.visualSize
            Layout.preferredHeight: root.visualSize
            Layout.alignment: Qt.AlignTop
            radius: Theme.radiusS
            color: "transparent"

            Image {
              id: visualImage
              anchors.fill: parent
              visible: card.visual !== "" && status !== Image.Error
              source: card.visual
              fillMode: Image.PreserveAspectCrop
              sourceSize.width:  root.visualSize * 2
              sourceSize.height: root.visualSize * 2
              asynchronous: true
            }

            // Ripiego: un glifo generico e' meglio di un buco.
            Text {
              anchors.centerIn: parent
              visible: !visualImage.visible
              text: Icons.app
              font.family: Theme.nerdFontFamily
              font.pixelSize: Theme.iconM
              color: Theme.foregroundDim
            }
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            // Intestazione: icona piccola dell'app se a sinistra c'e' un'immagine, nome, chiusura.
            RowLayout {
              Layout.fillWidth: true
              spacing: Theme.spacingS

              IconImage {
                visible: card.badge !== "" && status !== Image.Error
                source: card.badge
                implicitSize: Theme.fontM
                Layout.alignment: Qt.AlignVCenter
              }

              Text {
                text: card.modelData.appName
                color: Theme.foregroundDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontXs
                font.weight: Theme.weightNormal
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
              }

              // Chiude senza eseguire l'azione di default.
              Text {
                text: "×"
                color: closeHover.hovered ? Theme.foreground : Theme.foregroundDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontL
                font.weight: Theme.weightBold
                Layout.alignment: Qt.AlignVCenter

                HoverHandler {
                  id: closeHover
                  cursorShape: Qt.PointingHandCursor
                }

                // Presa esclusiva alla pressione: il click non arriva anche alla card sotto.
                TapHandler {
                  gesturePolicy: TapHandler.ReleaseWithinBounds
                  onTapped: card.modelData.dismiss()
                }
              }
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

            // Pulsanti azione: vanno a capo se non ci stanno su una riga.
            Flow {
              visible: card.buttons.length > 0
              Layout.fillWidth: true
              Layout.topMargin: Theme.spacingS
              spacing: Theme.spacingS

              Repeater {
                model: card.buttons

                delegate: Rectangle {
                  id: button
                  required property var modelData

                  implicitWidth:  label.implicitWidth + Theme.spacingL * 2
                  implicitHeight: label.implicitHeight + Theme.spacingS * 2
                  radius: Theme.radiusS
                  antialiasing: true
                  color: buttonHover.hovered ? Theme.surfaceHover : Theme.surfaceSolid

                  Behavior on color {
                    ColorAnimation { duration: Theme.durFast }
                  }

                  Text {
                    id: label
                    anchors.centerIn: parent
                    text: button.modelData.text
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontS
                    font.weight: Theme.weightBold
                  }

                  HoverHandler {
                    id: buttonHover
                    cursorShape: Qt.PointingHandCursor
                  }

                  // Presa esclusiva alla pressione: il click non arriva anche alla card sotto.
                  TapHandler {
                    gesturePolicy: TapHandler.ReleaseWithinBounds
                    onTapped: button.modelData.invoke()
                  }
                }
              }
            }
          }
        }

        HoverHandler {
          id: hover
          cursorShape: Qt.PointingHandCursor
        }

        // Click sulla card: l'azione di default se l'app ne ha una, altrimenti chiusura.
        TapHandler {
          onTapped: Notifications.activate(card.modelData)
        }
      }
    }
  }
}
