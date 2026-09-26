// WallpaperPicker.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "../../services"


ColumnLayout {
  id: root
  spacing: Theme.spacingM

  // Chiamata da chi ospita il picker, quando la finestra ha davvero il
  // focus Wayland: prima di quel momento un forceActiveFocus() si perde.
  function focusStrip() { strip.forceActiveFocus() }

  // Altezza comune; la carta aperta e' 16:9, le altre sono strisce.
  readonly property int cardH: 600
  readonly property int wideW: Math.round(root.cardH * 16 / 9)
  readonly property int narrowW: Math.round(root.cardH * 0.55)

  // Scarto orizzontale fra lato alto e lato basso della carta.
  readonly property int slant: Math.round(root.cardH * 0.22)

  // Spazio vero fra due carte, misurato lungo l'orizzontale.
  readonly property int gap: Theme.spacingM

  // Aria sopra e sotto la carta: lo stroke e gli spigoli vivi sporgono dalla forma.
  readonly property int strokeRoom: 4

  // Velo sulle strisce non selezionate; piu' leggero sotto il mouse.
  readonly property color veil:      Qt.rgba(0, 0, 0, 0.35)
  readonly property color veilHover: Qt.rgba(0, 0, 0, 0.15)

  // Distanza fra i centri di due strisce, e fra la carta aperta e la prima striscia.
  readonly property real step:      root.narrowW + root.gap - root.slant
  readonly property real firstStep: root.wideW / 2 + root.gap - root.slant + root.narrowW / 2

  // Strisce per lato che coprono meta' schermo, piu' una di margine.
  readonly property int halfCount: Math.ceil((strip.width / 2) / root.step) + 1

  readonly property int n: Wallpapers.count

  // Carta al centro.
  property int target: 0

  // Posizione disegnata: insegue target, e da lei derivano larghezze e posizioni.
  property real pos: root.target

  // Vero durante il salto da un capo all'altro: pos cambia di colpo, a striscia invisibile.
  property bool jumping: false

  // Spento finche' non si sincronizza: all'apertura si parte gia' sul wallpaper applicato.
  Behavior on pos {
    enabled: root.synced && !root.jumping
    NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutCubic }
  }

  // Limitato a n-1: se la cartella perde immagini, il cursore non punta nel vuoto.
  readonly property int currentIndex: Math.max(0, Math.min(root.target, root.n - 1))

  // Frecce, rotella e tap passano tutti da qui: ogni spostamento e' input.
  onTargetChanged: Drawers.poke()

  // Scarto del centro di una carta dal centro della striscia. Lineare fino a 1:
  // in mezzo le due carte si spartiscono la larghezza e i bordi restano a gap.
  function offsetFor(d) {
    const a = Math.abs(d)
    const off = a < 1 ? a * root.firstStep
                      : root.firstStep + (a - 1) * root.step
    return d < 0 ? -off : off
  }

  // Parte dall'immagine a meta' della cartella: carte da entrambi i lati, nessun vuoto all'apertura.
  property bool synced: false

  function startAtMiddle() {
    root.target = Math.floor((Wallpapers.count - 1) / 2)
  }

  // FolderListModel carica in asincrono: al Component.onCompleted puo'
  // essere ancora vuoto, quindi la partenza aspetta il conteggio.
  Component.onCompleted: if (Wallpapers.count > 0) { root.startAtMiddle(); root.synced = true }

  Connections {
    target: Wallpapers.model
    function onCountChanged() {
      if (!root.synced && Wallpapers.count > 0) {
        root.startAtMiddle()
        root.synced = true
      }
    }
  }

  function apply() {
    // Il pannello resta aperto dopo l'Invio: conta come input.
    Drawers.poke()
    const p = Wallpapers.pathAt(root.currentIndex)
    if (!p) return
    // Niente Drawers.close(): il pannello resta aperto cosi' vedi la shell
    // ricolorarsi e puoi provarne un altro senza riaprire.
    Wallpapers.apply(p)
  }

  // Dentro la striscia scorre; oltre un capo salta all'altro con una dissolvenza.
  function move(delta) {
    if (root.n === 0 || wrapJump.running) return
    const next = root.target + delta
    if (next >= 0 && next < root.n) {
      root.target = next
      return
    }
    wrapJump.landing = next < 0 ? root.n - 1 : 0
    wrapJump.restart()
  }

  // Scorrere fino all'altro capo farebbe sfilare tutte le carte: meglio sparire e ricomparire.
  SequentialAnimation {
    id: wrapJump
    property int landing: 0

    ScriptAction { script: root.jumping = true }
    NumberAnimation {
      target: strip; property: "opacity"; to: 0
      duration: Theme.durFast; easing.type: Easing.InCubic
    }
    ScriptAction { script: root.target = wrapJump.landing }
    NumberAnimation {
      target: strip; property: "opacity"; to: 1
      duration: Theme.durFast; easing.type: Easing.OutCubic
    }
    ScriptAction { script: root.jumping = false }
  }

  Item {
    id: strip

    Layout.fillWidth: true
    Layout.preferredHeight: root.cardH + root.strokeRoom * 2
    clip: true

    focus: true

    Keys.onLeftPressed:  root.move(-1)
    Keys.onRightPressed: root.move(1)

    // Return ed Enter sono due tasti diversi: il secondo e' quello del
    // tastierino, e senza questa riga non fa niente.
    Keys.onReturnPressed: root.apply()
    Keys.onEnterPressed:  root.apply()
    Keys.onEscapePressed: Drawers.close()

    // Lo scroll muove il cursore di una carta: la selezione resta discreta, come con le frecce.
    WheelHandler {
      onWheel: (event) => root.move(event.angleDelta.y > 0 ? -1 : 1)
    }

    Repeater {
      model: root.n

      delegate: Item {
        id: cell

        required property int index

        // Dipende da n: se la cartella cambia, il path si rilegge.
        readonly property string filePath: root.n > 0 ? Wallpapers.pathAt(cell.index) : ""

        // Distanza continua dal centro: 0 = aperta, 1 = prima striscia.
        readonly property real d: cell.index - root.pos
        readonly property real openness: Math.max(0, 1 - Math.abs(cell.d))

        // Fuori da qui la carta non si vede: niente immagine, niente layer.
        readonly property bool near: Math.abs(cell.d) <= root.halfCount

        readonly property bool highlighted: cell.index === root.currentIndex
        readonly property bool applied: Wallpapers.current !== ""
                                        && Wallpapers.current === cell.filePath

        width:  root.narrowW + (root.wideW - root.narrowW) * cell.openness
        height: root.cardH + root.strokeRoom * 2
        x: strip.width / 2 + root.offsetFor(cell.d) - cell.width / 2
        visible: cell.near

        // Sempre larga quanto la carta aperta e centrata: cambia la maschera, non l'immagine.
        Shape {
          id: frame
          x: (cell.width - root.wideW) / 2
          y: root.strokeRoom
          width:  root.wideW
          height: root.cardH

          // Lati della carta visibile nelle coordinate della forma. Non left/right: sono anchor line di Item.
          readonly property real edgeL: (root.wideW - cell.width) / 2
          readonly property real edgeR: frame.edgeL + cell.width

          // Antialiasing dei lati obliqui senza MSAA.
          preferredRendererType: Shape.CurveRenderer

          // Hover e tap solo dentro la forma: i rettangoli delle carte vicine si sovrappongono.
          containsMode: Shape.FillContains

          // Riempimento via layer: la texture di un Image nudo ignora il fillMode e deformerebbe.
          Item {
            id: thumb
            anchors.fill: parent
            visible: false
            layer.enabled: cell.near
            layer.smooth: true

            // Fondo mentre l'immagine carica.
            Rectangle {
              anchors.fill: parent
              color: Theme.surfaceSolid
            }

            Image {
              anchors.fill: parent
              // Solo vicino allo schermo; al ritorno la cache dei pixmap evita un nuovo decode.
              source: cell.near && cell.filePath !== "" ? "file://" + cell.filePath : ""
              fillMode: Image.PreserveAspectCrop
              clip: true

              // Basta per la scala 1.25 del Dell; a queste misure 2x sarebbe memoria sprecata.
              sourceSize.width: Math.round(root.wideW * 1.5)

              asynchronous: true
            }
          }

          // Immagine, senza bordo: il bordo sta sul path sopra, altrimenti il velo lo coprirebbe.
          ShapePath {
            fillItem: thumb
            strokeColor: "transparent"

            // Ultimo punto uguale al primo: il percorso si chiude senza tacca all'angolo.
            startX: frame.edgeL + root.slant
            startY: 0
            PathLine { x: frame.edgeR;              y: 0 }
            PathLine { x: frame.edgeR - root.slant; y: frame.height }
            PathLine { x: frame.edgeL;              y: frame.height }
            PathLine { x: frame.edgeL + root.slant; y: 0 }
          }

          // Velo e bordo: stessa forma, disegnata dopo l'immagine.
          ShapePath {
            fillColor: cell.highlighted  ? "transparent"
                     : cardHover.hovered ? root.veilHover
                     : root.veil

            // A riposo transparent, non larghezza 0: 0 disegnerebbe comunque una linea sottile.
            strokeWidth: cell.highlighted ? 3 : 2
            strokeColor: cell.highlighted ? Theme.accent
                       : cell.applied     ? Theme.foreground
                       : "transparent"

            // Spigoli vivi: il bordo segue gli angoli del riempimento.
            joinStyle: ShapePath.MiterJoin

            Behavior on fillColor {
              ColorAnimation { duration: Theme.durFast }
            }
            Behavior on strokeColor {
              ColorAnimation { duration: Theme.durFast }
            }

            startX: frame.edgeL + root.slant
            startY: 0
            PathLine { x: frame.edgeR;              y: 0 }
            PathLine { x: frame.edgeR - root.slant; y: frame.height }
            PathLine { x: frame.edgeL;              y: frame.height }
            PathLine { x: frame.edgeL + root.slant; y: 0 }
          }

          HoverHandler {
            id: cardHover
            cursorShape: Qt.PointingHandCursor
          }

          TapHandler {
            // Porta la carta al centro e applica: un click solo.
            onTapped: {
              root.target = cell.index
              root.apply()
            }
          }
        }
      }
    }
  }

  Text {
    visible: Wallpapers.count === 0
    Layout.fillWidth: true
    Layout.margins: Theme.spacingL
    text: "No images in " + Wallpapers.dir
    color: Theme.muted
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontM
    horizontalAlignment: Text.AlignHCenter
  }
}
