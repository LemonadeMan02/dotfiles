// Overview.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
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

  // Una riga per monitor, da sinistra a destra come sulla scrivania.
  readonly property var monitors: Hyprland.monitors.values.slice().sort((a, b) => a.x - b.x)

  // width e height sono pixel reali: nel rapporto la scala si annulla.
  function aspectOf(monitor) {
    return monitor.height > 0 ? monitor.width / monitor.height : 16 / 9
  }

  // Quota dello schermo che l'overview puo' prendere: attorno resta il desktop.
  readonly property real widthShare:  0.7
  readonly property real heightShare: 0.8

  FontMetrics {
    id: labelMetrics
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontXs
    font.weight: Theme.weightBold
  }

  // Larghezza di una miniatura, dallo schermo su cui si apre; l'altezza la decidono le proporzioni.
  // Vince il limite piu' stretto: le miniature in fila per larghezza, le righe impilate per altezza.
  readonly property int tileW: {
    const s = Drawers.screen
    const n = Workspaces.perMonitor
    if (!s || n < 1) return 260

    const byWidth = (s.width * root.widthShare - Theme.spacingM * (n - 1)) / n

    // Una riga e' alta tileW / aspetto: la somma degli inversi e' l'altezza per pixel di larghezza.
    const rows = root.monitors.length
    let perPixel = 0
    for (const m of root.monitors) perPixel += 1 / root.aspectOf(m)
    const labels = rows > 1 ? rows * (labelMetrics.height + Theme.spacingS) : 0
    const byHeight = perPixel > 0
        ? (s.height * root.heightShare - labels - Theme.spacingL * (rows - 1)) / perPixel
        : byWidth

    return Math.max(120, Math.floor(Math.min(byWidth, byHeight)))
  }

  // Sfondo applicato: ogni miniatura lo mostra velato, come un desktop in piccolo.
  readonly property string wallpaper: Wallpapers.current !== "" ? "file://" + Wallpapers.current : ""

  // Trascinamento in corso: "" = nessuno, "window" = una finestra, "workspace" = uno scambio.
  property string dragKind: ""
  property int dragFromWs: 0
  property string dragAddress: ""
  property string dragIcon: ""
  property string dragLabel: ""
  readonly property bool dragging: root.dragKind !== ""

  // Le anteprime sono un fotogramma solo: si rifanno a ogni riapertura e dopo uno spostamento.
  signal recapture()

  // lastIpcObject non si aggiorna da solo: posizioni e classi vanno richieste a ogni apertura.
  Component.onCompleted: Hyprland.refreshToplevels()

  // Riapertura a meta' uscita: il componente non rinasce, onCompleted non gira di nuovo.
  Connections {
    target: Drawers
    function onCurrentChanged() {
      if (!Drawers.isOpen("overview")) return
      Hyprland.refreshToplevels()
      root.recapture()
    }
  }

  // Dopo uno spostamento Hyprland riassesta le finestre: le posizioni nuove arrivano un attimo dopo.
  Timer {
    id: refreshLater
    interval: 150
    onTriggered: {
      Hyprland.refreshToplevels()
      root.recapture()
    }
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
        readonly property real aspect: root.aspectOf(row.modelData)

        // Larghezza logica: e' lo spazio in cui Hyprland esprime at e size delle finestre.
        readonly property real logicalW: row.modelData.width / Math.max(0.1, row.modelData.scale)

        // Il modello dal JSON di Hyprland: non cambia, quindi lastIpcObject non invecchia.
        // Con un solo schermo non distingue niente: via. Con due, chiaro solo quello col focus.
        Text {
          visible: root.monitors.length > 1
          text: row.modelData.lastIpcObject?.model ?? row.modelData.name
          color: row.modelData.focused ? Theme.foreground : Theme.muted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontXs
          font.weight: Theme.weightBold
          Layout.leftMargin: Theme.spacingXs
        }

        RowLayout {
          spacing: Theme.spacingM

          Repeater {
            model: Workspaces.perMonitor

            delegate: Item {
              id: tile
              required property int index

              readonly property int wsId: row.base + index
              readonly property var ws: Workspaces.byId(tile.wsId)
              readonly property bool active: row.modelData.activeWorkspace !== null
                                             && row.modelData.activeWorkspace.id === tile.wsId
              readonly property var windows: tile.ws ? tile.ws.toplevels.values : []

              // Stessa scala della barra: focused > urgente > attivo altrove > occupato > vuoto.
              readonly property bool focused: tile.active && row.modelData.focused
              readonly property bool urgent: tile.ws !== null && tile.ws.urgent && !tile.focused
              readonly property bool empty: tile.windows.length === 0

              // Da coordinate logiche di Hyprland a pixel della miniatura.
              readonly property real k: tile.width / Math.max(1, row.logicalW)

              // Finestra sotto il mouse, per la didascalia. Vale solo finche' e' ancora qui:
              // chiusa o trascinata via, il suo delegate sparisce senza avvisare l'hover.
              property var hoveredWin: null
              readonly property var captionWin: (tile.hoveredWin !== null
                                                 && tile.windows.indexOf(tile.hoveredWin) !== -1)
                                                ? tile.hoveredWin : null

              // Il titolo resta scritto mentre la didascalia sfuma.
              property string lastTitle: ""
              onCaptionWinChanged: if (tile.captionWin) tile.lastTitle = tile.captionWin.title

              implicitWidth:  root.tileW
              implicitHeight: Math.round(root.tileW / row.aspect)

              // La miniatura che si sta scambiando resta al suo posto, sbiadita.
              opacity: (root.dragKind === "workspace" && root.dragFromWs === tile.wsId) ? 0.5 : 1.0

              // Il ritaglio arrotondato serve a sfondo e anteprime: clip su un Rectangle fa angoli vivi.
              ClippingRectangle {
                id: face
                anchors.fill: parent
                radius: Theme.radiusS
                antialiasing: true

                // Si vede solo se lo sfondo manca o sta ancora caricando.
                color: Theme.surfaceSolid

                // Cornice sopra il contenuto: le anteprime non la coprono e non si spostano col suo spessore.
                contentUnderBorder: true

                // Una sola cornice in accento, quella dove sei: le altre non gli rubano l'occhio.
                // Il bersaglio del trascinamento vince su tutto, in chiaro per non confondersi.
                border.width: (drop.containsDrag || tile.focused || tile.urgent) ? 2
                            : tile.empty                                        ? 1
                                                                                : 0
                border.color: drop.containsDrag ? Theme.foreground
                            : tile.focused      ? Theme.accent
                            : tile.urgent       ? Theme.urgent
                                                : Theme.border

                Image {
                  anchors.fill: parent
                  visible: root.wallpaper !== ""
                  source: root.wallpaper
                  fillMode: Image.PreserveAspectCrop

                  // Stessa misura in tutta la riga: la cache decodifica l'immagine una volta sola.
                  // 1.5 basta per la scala 1.25 del Dell, come nel carosello degli sfondi.
                  sourceSize.width:  Math.round(root.tileW * 1.5)
                  sourceSize.height: Math.round(tile.implicitHeight * 1.5)

                  asynchronous: true
                }

                // Velo: fitto sul vuoto, leggero sul pieno, quasi via sotto il mouse e sul bersaglio.
                Rectangle {
                  anchors.fill: parent
                  color: Theme.withAlpha(Theme.scrim,
                                         (hover.hovered || drop.containsDrag) ? 0.15
                                         : tile.empty                         ? 0.6
                                                                              : 0.35)

                  Behavior on color {
                    ColorAnimation { duration: Theme.durFast }
                  }
                }

                Repeater {
                  model: tile.windows

                  delegate: Item {
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

                    ClippingRectangle {
                      anchors.fill: parent
                      radius: Theme.radiusS / 2
                      antialiasing: true

                      // Finche' l'anteprima non arriva, o se non arriva, il riquadro tenue di prima.
                      color: Theme.withAlpha(Theme.foreground, 0.10)
                      contentUnderBorder: true

                      border.width: win.modelData.activated ? 2 : 1
                      border.color: win.modelData.activated ? Theme.accent
                                  : winHover.hovered         ? Theme.foreground
                                                             : Theme.border

                      // Un fotogramma solo, non live: dieci workspace in diretta a 4K costerebbero troppo.
                      // La cattura parte da sola quando la sorgente c'e'; recapture() la rifa.
                      ScreencopyView {
                        id: preview
                        anchors.fill: parent
                        captureSource: win.modelData.wayland
                        live: false

                        opacity: preview.hasContent ? 1 : 0
                        Behavior on opacity {
                          NumberAnimation { duration: Theme.durFast }
                        }
                      }
                    }

                    Connections {
                      target: root
                      function onRecapture() { if (preview.hasContent) preview.captureFrame() }
                    }

                    // Con l'anteprima l'icona e' un distintivo in basso; senza, sta grande al centro.
                    // Sulle finestre minuscole il distintivo coprirebbe tutto: via.
                    Rectangle {
                      id: iconBox
                      readonly property bool compact: preview.hasContent
                      readonly property real side: iconBox.compact
                          ? Math.min(Theme.iconM, win.width * 0.3, win.height * 0.3)
                          : Math.min(Theme.iconL, win.width * 0.5, win.height * 0.5)

                      visible: !iconBox.compact || Math.min(win.width, win.height) >= 48
                      width:  iconBox.side + (iconBox.compact ? Theme.spacingS * 2 : 0)
                      height: iconBox.width
                      x: (win.width - iconBox.width) / 2
                      y: iconBox.compact ? win.height - iconBox.height - Theme.spacingS
                                         : (win.height - iconBox.height) / 2

                      radius: Theme.radiusS
                      antialiasing: true
                      color: iconBox.compact ? Theme.surface : "transparent"

                      IconImage {
                        id: winIcon
                        anchors.centerIn: parent
                        width:  iconBox.side
                        height: iconBox.side
                        visible: win.iconSource !== "" && status !== Image.Error
                        source: win.iconSource
                      }

                      // Ripiego: un glifo generico e' meglio di un buco.
                      Text {
                        anchors.centerIn: parent
                        visible: !winIcon.visible
                        text: Icons.app
                        font.family: Theme.nerdFontFamily
                        font.pixelSize: iconBox.side
                        color: Theme.foregroundDim
                      }
                    }

                    HoverHandler {
                      id: winHover
                      cursorShape: Qt.PointingHandCursor
                      onHoveredChanged: {
                        if (winHover.hovered) tile.hoveredWin = win.modelData
                        else if (tile.hoveredWin === win.modelData) tile.hoveredWin = null
                      }
                    }

                    // Sinistro: vai a questa finestra. Centrale: chiudila, l'overview resta aperta.
                    // Presa esclusiva alla pressione: il tap non arriva anche alla miniatura sotto.
                    // Il DragHandler qui accanto la puo' comunque rilevare oltre la soglia.
                    TapHandler {
                      acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                      gesturePolicy: TapHandler.ReleaseWithinBounds

                      onTapped: (eventPoint, button) => {
                        if (button === Qt.MiddleButton) {
                          tile.hoveredWin = null
                          Workspaces.closeWindow(win.modelData.address)
                          refreshLater.restart()
                          Drawers.poke()
                        } else {
                          // Chiudi prima: il focus grab sopravvivrebbe al cambio di workspace.
                          Drawers.close()
                          Workspaces.focusWindow(win.modelData.address)
                        }
                      }
                    }

                    // target null: il riquadro resta fermo, si muove il fantasma fuori dal ritaglio.
                    DragHandler {
                      target: null
                      enabled: Workspaces.windowSelector(win.modelData.address) !== ""
                      cursorShape: Qt.ClosedHandCursor

                      onActiveChanged: {
                        if (active) {
                          tile.hoveredWin = null
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
              }

              // Letto da finishDrag() tramite Drag.target del fantasma.
              DropArea {
                id: drop
                anchors.fill: parent
                keys: ["overview"]
                readonly property int wsId: tile.wsId
              }

              // Maniglia del workspace, sopra le finestre: trascinata su un'altra miniatura le scambia.
              Rectangle {
                id: handle
                z: 2
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: Theme.spacingS
                width:  Math.max(height, badge.implicitWidth + Theme.spacingM)
                height: badge.implicitHeight + Theme.spacingS * 2
                radius: Theme.radiusS
                antialiasing: true

                // Pieno dove sei o dove si chiede attenzione. Altrove il fondo della shell:
                // sopra lo sfondo un numero nudo non si leggerebbe.
                color: tile.focused       ? Theme.accent
                     : tile.urgent        ? Theme.urgent
                     : badgeHover.hovered ? Theme.surfaceHover
                                          : Theme.surface

                // A schermo sull'altro monitor: contorno, come nella barra.
                border.width: tile.active && !tile.focused ? 2 : 0
                border.color: Theme.accent

                Text {
                  id: badge
                  anchors.centerIn: parent
                  text: tile.index + 1
                  color: tile.focused                ? Theme.onAccent
                       : tile.urgent                 ? Theme.onUrgent
                       : tile.empty && !tile.active  ? Theme.muted
                                                     : Theme.foreground
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontS
                  font.weight: Theme.weightBold
                }

                HoverHandler {
                  id: badgeHover
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

              // Didascalia accanto alla maniglia: il titolo della finestra sotto il mouse.
              // In alto e non in basso: i distintivi delle icone stanno in fondo alle finestre.
              Rectangle {
                z: 2
                anchors.left: handle.right
                anchors.leftMargin: Theme.spacingS
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacingS
                anchors.top: handle.top
                height: handle.height
                radius: Theme.radiusS
                antialiasing: true
                color: Theme.surface

                opacity: tile.captionWin !== null && !root.dragging ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                  NumberAnimation { duration: Theme.durFast }
                }

                Text {
                  anchors.left: parent.left
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.leftMargin: Theme.spacingM
                  anchors.rightMargin: Theme.spacingM
                  text: tile.captionWin ? tile.captionWin.title : tile.lastTitle
                  textFormat: Text.PlainText
                  elide: Text.ElideRight
                  color: Theme.foreground
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontXs
                  font.weight: Theme.weightBold
                }
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
