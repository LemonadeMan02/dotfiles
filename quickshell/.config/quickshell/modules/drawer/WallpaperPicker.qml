// WallpaperPicker.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../common"
import "../../services"


ColumnLayout {
  id: root
  spacing: Theme.spacingM

  // Chiamata da chi ospita il picker, quando la finestra ha davvero il
  // focus Wayland: prima di quel momento un forceActiveFocus() si perde.
  function focusStrip() { strip.forceActiveFocus() }

  readonly property int thumbW: 240
  readonly property int thumbH: 135

  // Il cursore parte sul wallpaper gia' applicato, non su zero: aprire il
  // pannello e trovarsi altrove e' disorientante.
  property bool synced: false

  function syncToCurrent() {
    for (let i = 0; i < Wallpapers.count; i++) {
      if (Wallpapers.pathAt(i) === Wallpapers.current) {
        strip.currentIndex = i
        return
      }
    }
    strip.currentIndex = 0
  }

  // FolderListModel carica in asincrono: al Component.onCompleted puo'
  // essere ancora vuoto, quindi la sincronizzazione aspetta il conteggio.
  Component.onCompleted: if (Wallpapers.count > 0) { root.syncToCurrent(); root.synced = true }

  Connections {
    target: Wallpapers.model
    function onCountChanged() {
      if (!root.synced && Wallpapers.count > 0) {
        root.syncToCurrent()
        root.synced = true
      }
    }
  }

  function apply() {
    // Il pannello resta aperto dopo l'Invio: conta come input.
    Drawers.poke()
    const p = Wallpapers.pathAt(strip.currentIndex)
    if (!p) return
    // Niente Drawers.close(): il pannello resta aperto cosi' vedi la shell
    // ricolorarsi e puoi provarne un altro senza riaprire.
    Wallpapers.apply(p)
  }

  function move(delta) {
    const n = Wallpapers.count
    if (n === 0) return
    // Modulo con correzione: in JS -1 % 8 fa -1, non 7.
    strip.currentIndex = ((strip.currentIndex + delta) % n + n) % n
  }

  ListView {
    id: strip

    Layout.fillWidth: true
    Layout.preferredHeight: root.thumbH + Theme.fontXs + Theme.spacingM * 3

    orientation: ListView.Horizontal
    model: Wallpapers.model
    spacing: Theme.spacingM
    clip: true

    // Il cursore resta in mezzo e scorre la striscia sotto, invece di
    // correre fino al bordo e fermarsi li'.
    highlightRangeMode: ListView.ApplyRange
    preferredHighlightBegin: width / 2 - root.thumbW / 2
    preferredHighlightEnd:   width / 2 + root.thumbW / 2
    highlightMoveDuration: Theme.durSlow

    focus: true
    keyNavigationEnabled: true
    keyNavigationWraps: true

    // Frecce, rotella e tap passano tutti da qui: ogni spostamento e' input.
    onCurrentIndexChanged: Drawers.poke()

    // Return ed Enter sono due tasti diversi: il secondo e' quello del
    // tastierino, e senza questa riga non fa niente.
    Keys.onReturnPressed: root.apply()
    Keys.onEnterPressed:  root.apply()
    Keys.onEscapePressed: Drawers.close()

    // Lo scroll muove il cursore invece di far scivolare la vista: la
    // selezione resta discreta, come con le frecce.
    WheelHandler {
      onWheel: (event) => root.move(event.angleDelta.y > 0 ? -1 : 1)
    }

    delegate: Item {
      id: cell

      required property int index
      required property string filePath
      required property string fileName

      width:  root.thumbW
      height: root.thumbH + Theme.fontXs + Theme.spacingXs

      readonly property bool highlighted: strip.currentIndex === cell.index
      readonly property bool applied: Wallpapers.current !== ""
                                      && Wallpapers.current === cell.filePath

      // Cornice e miniatura separate: il bordo deve stare fuori dal
      // ritaglio, altrimenti l'immagine ci passa sopra.
      Rectangle {
        id: frame
        width:  root.thumbW
        height: root.thumbH

        radius: Theme.radiusS
        antialiasing: true
        color: Theme.surfaceSolid

        border.width: cell.highlighted ? 3 : (cell.applied ? 2 : 0)
        border.color: cell.highlighted ? Theme.accent : Theme.foregroundDim

        transformOrigin: Item.Center
        scale: cell.highlighted ? 1.05 : 1.0

        Behavior on scale {
          NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
        }
        Behavior on border.color {
          ColorAnimation { duration: Theme.durFast }
        }

        // ClippingRectangle e' di Quickshell.Widgets: ritaglia i figli
        // sugli angoli tondi, cosa che un Item con clip non sa fare.
        ClippingRectangle {
          anchors.fill: parent
          anchors.margins: frame.border.width
          radius: Theme.radiusS
          color: "transparent"

          Image {
            anchors.fill: parent
            source: "file://" + cell.filePath
            fillMode: Image.PreserveAspectCrop

            // Senza questo il decoder tiene in RAM il PNG 4K intero per
            // disegnarlo a 240px: su una cartella piena sono gigabyte.
            sourceSize.width: root.thumbW * 2

            asynchronous: true
          }
        }

        HoverHandler {
          cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
          // Il tap sposta il cursore e applica: un click solo, come previsto.
          onTapped: {
            strip.currentIndex = cell.index
            root.apply()
          }
        }
      }

      Text {
        anchors.top: frame.bottom
        anchors.topMargin: Theme.spacingXs
        width: root.thumbW

        text: cell.fileName
        // L'accento marca quello applicato: e' l'unico stato che sopravvive
        // alla chiusura del pannello, e va distinto dal cursore.
        color: cell.applied ? Theme.accent : Theme.foregroundDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontXs
        font.weight: cell.applied ? Theme.weightBold : Theme.weightNormal
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideMiddle

        Behavior on color {
          ColorAnimation { duration: Theme.durFast }
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
