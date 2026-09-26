// Overview.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import "../../services"


// Item e non ColumnLayout: il fantasma del trascinamento non deve finire impaginato fra le righe.
Item {
  id: root

  implicitWidth:  column.implicitWidth
  implicitHeight: column.implicitHeight

  // Chiamata da chi ospita l'overview quando la finestra ha il focus Wayland: prima si perderebbe.
  function focusOverview() { root.forceActiveFocus() }

  Keys.onEscapePressed: Drawers.close()

  // Larghezza di una miniatura; l'altezza la decidono le proporzioni del monitor.
  readonly property int tileW: 260

  // Una riga per monitor, da sinistra a destra come sulla scrivania.
  readonly property var monitors: Hyprland.monitors.values.slice().sort((a, b) => a.x - b.x)

  // Trascinamento in corso: "" = nessuno, "window" = una finestra, "workspace" = uno scambio.
  property string dragKind: ""
  property int dragFromWs: 0
  property string dragAddress: ""
  property string dragIcon: ""
  property string dragLabel: ""
  readonly property bool dragging: root.dragKind !== ""

  // lastIpcObject non si aggiorna da solo: posizioni e classi vanno richieste a ogni apertura.
  Component.onCompleted: Hyprland.refreshToplevels()

  // Riapertura a meta' uscita: il componente non rinasce, onCompleted non gira di nuovo.
  Connections {
    target: Drawers
    function onCurrentChanged() {
      if (Drawers.isOpen("overview")) Hyprland.refreshToplevels()
    }
  }

  // Dopo uno spostamento Hyprland riassesta le finestre: le posizioni nuove arrivano un attimo dopo.
  Timer {
    id: refreshLater
    interval: 150
    onTriggered: Hyprland.refreshToplevels()
  }

  // Icona di sistema dall'appId; "" se non si trova, e il chiamante ripiega sul glifo.
  function iconFor(appId) {
    if (!appId) return ""
    return Apps.iconFor(DesktopEntries.heuristicLookup(appId))
  }

  // Centra il fantasma sul puntatore; la posizione arriva in coordinate della scena.
  function moveGhost(scenePos) {
    const p = root.mapFromItem(null, scenePos.x, scenePos.y)
    ghost.x = p.x - ghost.width / 2
    ghost.y = p.y - ghost.height / 2
  }

  // Rilascio: agisce solo se sotto il fantasma c'e' un workspace diverso da quello di partenza.
  function finishDrag() {
    const target = ghost.Drag.target
    if (target && target.wsId !== root.dragFromWs) {
      if (root.dragKind === "window")
        Workspaces.moveWindow(root.dragAddress, target.wsId)
      else
        Workspaces.swap(root.dragFromWs, target.wsId)
      refreshLater.restart()
    }
    root.dragKind = ""
    root.dragAddress = ""
    Drawers.poke()
  }

  ColumnLayout {
    id: column
    width: parent.width
    spacing: Theme.spacingL

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

              // La miniatura che si sta scambiando resta al suo posto, sbiadita.
              opacity: (root.dragKind === "workspace" && root.dragFromWs === tile.wsId) ? 0.5 : 1.0

              // Bersaglio del trascinamento: contorno chiaro, distinto dall'accento dell'attivo.
              border.width: (drop.containsDrag || tile.active) ? 2 : 0
              border.color: drop.containsDrag ? Theme.foreground : Theme.accent

              Behavior on color {
                ColorAnimation { duration: Theme.durFast }
              }

              // Letto da finishDrag() tramite Drag.target del fantasma.
              DropArea {
                id: drop
                anchors.fill: parent
                keys: ["overview"]
                readonly property int wsId: tile.wsId
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

                  // L'originale resta al suo posto, sbiadito, finche' il fantasma e' in giro.
                  opacity: (root.dragKind === "window"
                            && root.dragAddress === win.modelData.address) ? 0.3 : 1.0

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

                  HoverHandler {
                    cursorShape: Qt.OpenHandCursor
                  }

                  // target null: il rettangolo resta fermo, si muove il fantasma fuori dal ritaglio.
                  DragHandler {
                    target: null
                    enabled: win.modelData.address !== ""
                    cursorShape: Qt.ClosedHandCursor

                    onActiveChanged: {
                      if (active) {
                        root.moveGhost(centroid.scenePosition)
                        root.dragIcon = win.iconSource
                        root.dragFromWs = tile.wsId
                        root.dragAddress = win.modelData.address
                        root.dragKind = "window"
                      } else if (root.dragging) {
                        root.finishDrag()
                      }
                    }
                    onCentroidChanged: if (active) root.moveGhost(centroid.scenePosition)
                  }
                }
              }

              // Maniglia del workspace, sopra le finestre: trascinata su un'altra miniatura le scambia.
              Rectangle {
                z: 2
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: Theme.spacingS
                width:  Math.max(height, badge.implicitWidth + Theme.spacingM)
                height: badge.implicitHeight + Theme.spacingS * 2
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

                HoverHandler {
                  cursorShape: Qt.OpenHandCursor
                }

                DragHandler {
                  target: null
                  cursorShape: Qt.ClosedHandCursor

                  onActiveChanged: {
                    if (active) {
                      root.moveGhost(centroid.scenePosition)
                      root.dragLabel = String(tile.index + 1)
                      root.dragFromWs = tile.wsId
                      root.dragKind = "workspace"
                    } else if (root.dragging) {
                      root.finishDrag()
                    }
                  }
                  onCentroidChanged: if (active) root.moveGhost(centroid.scenePosition)
                }
              }

              Text {
                anchors.centerIn: parent
                visible: tile.windows.length === 0
                text: "Empty"
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
              // Un trascinamento oltre la soglia annulla il tap: niente cambio involontario.
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

  // Fantasma: segue il puntatore sopra tutto, e porta la drag alle DropArea delle miniature.
  Rectangle {
    id: ghost
    z: 10
    visible: root.dragging

    width: 64
    height: 44
    radius: Theme.radiusS
    antialiasing: true
    color: Theme.surfaceSolid
    border.width: 2
    border.color: Theme.accent

    Drag.active: root.dragging
    Drag.keys: ["overview"]
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    // Scambio: il numero del workspace trascinato.
    Text {
      anchors.centerIn: parent
      visible: root.dragKind === "workspace"
      text: root.dragLabel
      color: Theme.foreground
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontL
      font.weight: Theme.weightBold
    }

    // Finestra: la sua icona, o il glifo generico.
    IconImage {
      id: ghostIcon
      anchors.centerIn: parent
      width:  Theme.iconM
      height: Theme.iconM
      visible: root.dragKind === "window" && root.dragIcon !== "" && status !== Image.Error
      source: root.dragIcon
    }

    Text {
      anchors.centerIn: parent
      visible: root.dragKind === "window" && !ghostIcon.visible
      text: Icons.app
      font.family: Theme.nerdFontFamily
      font.pixelSize: Theme.iconM
      color: Theme.foregroundDim
    }
  }
}
