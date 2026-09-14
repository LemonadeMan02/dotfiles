// DrawerWindow.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../services"

PanelWindow {
  id: root

  screen: Drawers.screen

  WlrLayershell.namespace: "quickshell:drawer"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

  exclusiveZone: 0
  color: "transparent"

  // Incollato al bordo inferiore: gli angoli bassi restano vivi.
  anchors.bottom: true
  margins.bottom: 0

  readonly property int cornerRadius: 20

  // Aria sopra il pannello: esiste solo perche' il rimbalzo lo porta oltre
  // la quota di riposo. Senza, gli angoli alti verrebbero tranciati.
  readonly property int overshootRoom: 28

  // Altezza del solo pannello, senza l'aria del rimbalzo.
  readonly property real panelFullH: layout.implicitHeight + Theme.spacingM * 2

  implicitWidth:  Math.max(400, layout.implicitWidth + Theme.spacingM * 2)
  implicitHeight: root.panelFullH + root.overshootRoom

  // Durata dell'entrata. Piu' lunga di durSlow: il rimbalzo ha bisogno di
  // tempo per leggersi, sotto i 250ms diventa uno scatto.
  readonly property int animDuration: 300

  // Stato locale dell'animazione. Parte false anche quando il drawer e'
  // gia' logicamente aperto: e' l'unico modo per avere una transizione
  // invece di una comparsa secca al primo frame.
  property bool shown: false

  // 0 = pannello sotto il bordo, 1 = a riposo. OutBack lo porta oltre 1.
  property real reveal: shown ? 1 : 0

  Behavior on reveal {
    NumberAnimation {
      duration: root.animDuration
      easing.type: Easing.OutBack
      // Default 1.70158: troppo, servirebbe il doppio di overshootRoom.
      easing.overshoot: 1.1
    }
  }

  // Il bordo superiore del pannello. E' questo a muoversi: il fondo resta
  // incollato al bordo dello schermo.
  readonly property real panelTop: Math.max(0, Math.min(root.height,
      root.overshootRoom + root.panelFullH * (1 - root.reveal)))

  readonly property real panelH: root.height - root.panelTop

  // Clampato sull'altezza disponibile: nei primi frame il pannello e' alto
  // pochi pixel e un raggio da 20 lo deformerebbe.
  readonly property real cr: Math.min(root.cornerRadius, root.panelH / 2)

  Component.onCompleted: {
    Drawers.registerWindow(root)
    // Rimandato di un ciclo: se lo scrivessi qui, il valore iniziale e
    // quello finale verrebbero applicati insieme e il Behavior non scatta.
    Qt.callLater(() => root.shown = true)
  }

  Connections {
    target: Drawers
    function onVisibleChanged() {
      root.shown = Drawers.visible
      if (Drawers.visible) exitTimer.stop()
      else exitTimer.restart()
    }
  }

  // Smontaggio temporizzato invece che agganciato a onFinished del
  // Behavior: qui il momento della fine e' esplicito e verificabile.
  Timer {
    id: exitTimer
    interval: root.animDuration + 20
    onTriggered: Drawers.unload()
  }

  Rectangle {
    x: 0
    y: root.panelTop
    width: root.width
    height: root.panelH

    // Solo in alto: gli angoli bassi muoiono contro il bordo dello schermo
    // e arrotondarli lascerebbe due spicchi di vuoto.
    topLeftRadius:  root.cr
    topRightRadius: root.cr

    color: Theme.surface
    antialiasing: true

    Behavior on color {
      ColorAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
    }

    // L'hover sta qui e non sul layout: dentro ci sono righe con i loro
    // HoverHandler, e l'auto-close non deve dipendere da chi vince.
    HoverHandler {
      onHoveredChanged: Drawers.hovered = hovered
    }
  }

  // Il contenuto sale col bordo del pannello. Sotto il bordo inferiore
  // della superficie non viene composto: e' li' che sparisce.
  ColumnLayout {
    id: layout

    x: Theme.spacingM
    y: root.panelTop + Theme.spacingM
    width: root.width - Theme.spacingM * 2

    spacing: Theme.spacingXs

    QuickSettings {
      Layout.fillWidth: true
    }
  }

  // Regione d'input agganciata al solo pannello: l'aria sopra resta
  // click-through anche durante il rimbalzo.
  mask: Region {
    x: 0
    y: root.panelTop
    width:  root.width
    height: root.panelH
  }
}
