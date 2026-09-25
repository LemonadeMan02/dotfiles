// Overview.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
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

  // lastIpcObject non si aggiorna da solo: posizioni e classi vanno richieste a ogni apertura.
  Component.onCompleted: Hyprland.refreshToplevels()

  // Riapertura a meta' uscita: il componente non rinasce, onCompleted non gira di nuovo.
  Connections {
    target: Drawers
    function onCurrentChanged() {
      if (Drawers.isOpen("overview")) Hyprland.refreshToplevels()
    }
  }

  // Icona di sistema dall'appId; "" se non si trova, e il chiamante ripiega sul glifo.
  function iconFor(appId) {
    if (!appId) return ""
    return Apps.iconFor(DesktopEntries.heuristicLookup(appId))
  }

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

      // Larghezza logica: e' lo spazio in cui Hyprland esprime at e size delle finestre.
      readonly property real logicalW: row.modelData.width / Math.max(0.1, row.modelData.scale)

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
            readonly property var windows: tile.ws ? tile.ws.toplevels.values : []

            // Da coordinate logiche di Hyprland a pixel della miniatura.
            readonly property real k: tile.width / Math.max(1, row.logicalW)

            implicitWidth:  root.tileW
            implicitHeight: Math.round(root.tileW / row.aspect)

            radius: Theme.radiusS
            antialiasing: true
            clip: true
            color: hover.hovered ? Theme.surfaceHover : Theme.surfaceSolid

            border.width: tile.active ? 2 : 0
            border.color: Theme.accent

            Behavior on color {
              ColorAnimation { duration: Theme.durFast }
            }

            Repeater {
              model: tile.windows

              delegate: Rectangle {
                id: win
                required property var modelData

                readonly property var ipc: win.modelData.lastIpcObject
                // Prima del refresh il JSON puo' mancare: meglio niente che un rettangolo in 0,0.
                readonly property bool known: win.ipc?.at !== undefined && win.ipc?.size !== undefined

                readonly property string appId: win.modelData.wayland?.appId
                                                ?? win.ipc?.class ?? ""
                readonly property string iconSource: root.iconFor(win.appId)

                visible: win.known
                x: win.known ? (win.ipc.at[0] - row.modelData.x) * tile.k : 0
                y: win.known ? (win.ipc.at[1] - row.modelData.y) * tile.k : 0
                width:  win.known ? Math.max(4, win.ipc.size[0] * tile.k) : 0
                height: win.known ? Math.max(4, win.ipc.size[1] * tile.k) : 0

                // Le flottanti sopra le affiancate, come sullo schermo.
                z: win.ipc?.floating ? 1 : 0

                radius: Theme.radiusS / 2
                antialiasing: true
                color: Theme.withAlpha(Theme.foreground, 0.10)
                border.width: win.modelData.activated ? 2 : 1
                border.color: win.modelData.activated ? Theme.accent : Theme.border

                // Contenitore quadrato: l'icona non supera meta' del lato piu' corto.
                Item {
                  anchors.centerIn: parent
                  width:  Math.min(Theme.iconL, parent.width * 0.5, parent.height * 0.5)
                  height: width

                  IconImage {
                    id: winIcon
                    anchors.fill: parent
                    visible: win.iconSource !== "" && status !== Image.Error
                    source: win.iconSource
                  }

                  // Ripiego: un glifo generico e' meglio di un buco.
                  Text {
                    anchors.centerIn: parent
                    visible: !winIcon.visible
                    text: Icons.app
                    font.family: Theme.nerdFontFamily
                    font.pixelSize: parent.height
                    color: Theme.foregroundDim
                  }
                }
              }
            }

            // Numero sopra le finestre: su una miniatura piena resterebbe coperto.
            Rectangle {
              z: 2
              anchors.left: parent.left
              anchors.top: parent.top
              anchors.margins: Theme.spacingS
              width:  Math.max(height, badge.implicitWidth + Theme.spacingM)
              height: badge.implicitHeight + Theme.spacingXs * 2
              radius: Theme.radiusS
              antialiasing: true
              color: tile.active ? Theme.accent : Theme.surface

              Text {
                id: badge
                anchors.centerIn: parent
                text: tile.index + 1
                color: tile.active ? Theme.onAccent : Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontS
                font.weight: Theme.weightBold
              }
            }

            Text {
              anchors.centerIn: parent
              visible: tile.windows.length === 0
              text: "Vuoto"
              color: Theme.muted
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
