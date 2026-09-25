// Overview.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../services"


ColumnLayout {
  id: root
  spacing: Theme.spacingL

  // Chiamata da chi ospita l'overview quando la finestra ha il focus Wayland: prima si perderebbe.
  function focusOverview() { root.forceActiveFocus() }

  Keys.onEscapePressed: Drawers.close()

  // Larghezza di una miniatura; l'altezza la decidono le proporzioni del monitor.
  readonly property int tileW: 260

  // Una riga per monitor, da sinistra a destra come sulla scrivania.
  readonly property var monitors: Hyprland.monitors.values.slice().sort((a, b) => a.x - b.x)

  Repeater {
    model: root.monitors

    delegate: ColumnLayout {
      id: row
      required property var modelData

      Layout.alignment: Qt.AlignHCenter
      spacing: Theme.spacingS

      readonly property int base: Workspaces.baseFor(row.modelData)

      // width e height sono pixel reali: nel rapporto la scala si annulla.
      readonly property real aspect: row.modelData.height > 0
                                     ? row.modelData.width / row.modelData.height
                                     : 16 / 9

      // Il modello dal JSON di Hyprland: non cambia, quindi lastIpcObject non invecchia.
      Text {
        text: row.modelData.lastIpcObject?.model ?? row.modelData.name
        color: Theme.foregroundDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontXs
        font.weight: Theme.weightBold
        Layout.leftMargin: Theme.spacingXs
      }

      RowLayout {
        spacing: Theme.spacingM

        Repeater {
          model: Workspaces.perMonitor

          delegate: Rectangle {
            id: tile
            required property int index

            readonly property int wsId: row.base + index
            readonly property var ws: Workspaces.byId(tile.wsId)
            readonly property bool active: row.modelData.activeWorkspace !== null
                                           && row.modelData.activeWorkspace.id === tile.wsId
            readonly property int windowCount: tile.ws ? tile.ws.toplevels.values.length : 0

            implicitWidth:  root.tileW
            implicitHeight: Math.round(root.tileW / row.aspect)

            radius: Theme.radiusS
            antialiasing: true
            color: hover.hovered ? Theme.surfaceHover : Theme.surfaceSolid

            border.width: tile.active ? 2 : 0
            border.color: Theme.accent

            Behavior on color {
              ColorAnimation { duration: Theme.durFast }
            }

            // Posizione nel blocco, come nella barra.
            Text {
              anchors.left: parent.left
              anchors.top: parent.top
              anchors.margins: Theme.spacingM
              text: tile.index + 1
              color: tile.active ? Theme.accent : Theme.foreground
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontM
              font.weight: Theme.weightBold
            }

            // Segnaposto fino al passo 3c, quando al posto del conteggio arrivano le finestre.
            Text {
              anchors.centerIn: parent
              text: tile.windowCount === 0 ? "Vuoto"
                  : tile.windowCount === 1 ? "1 finestra"
                  : tile.windowCount + " finestre"
              color: tile.windowCount === 0 ? Theme.muted : Theme.foregroundDim
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontS
              font.weight: Theme.weightNormal
            }

            HoverHandler {
              id: hover
              cursorShape: Qt.PointingHandCursor
            }

            // Chiudi prima: il focus grab sopravvivrebbe al cambio di workspace.
            TapHandler {
              onTapped: {
                Drawers.close()
                Workspaces.focus(tile.wsId)
              }
            }
          }
        }
      }
    }
  }
}
