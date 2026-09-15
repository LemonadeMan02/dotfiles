// Drawer.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../services"

PanelWindow {
  id: root

  // ── Configurazione. Ancoraggi e margini non stanno qui: li scrive chi
  //    istanzia, perche' questo e' gia' un PanelWindow. ────────────────
  required property string name

  // "bottom", "top" o "center". I primi due entrano traslando dal bordo,
  // il terzo non ha un bordo da cui entrare e usa scala + dissolvenza.
  property string edge: "bottom"

  property int minWidth: 400

  // Separati: un pannello incollato a un bordo dello schermo vuole gli
  // angoli di quel lato vivi, uno che galleggia li vuole tutti tondi.
  property int topRadius:    20
  property int bottomRadius: 20

  // I launcher vogliono i tasti appena aperti, i pannelli da cliccare no.
  property bool grabKeyboard: false

  signal focusReady()

  default property alias content: layout.data

  screen: Drawers.screen

  WlrLayershell.namespace: "quickshell:drawer"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

  exclusiveZone: 0
  color: "transparent"

  readonly property bool centered:   root.edge === "center"
  readonly property bool fromBottom: root.edge === "bottom"

  // Aria oltre la quota di riposo. Per i cassetti a bordo serve al rimbalzo
  // della traslazione; per quello centrale al sovradimensionamento della scala.
  readonly property int overshootRoom: 28

  // Dimensioni del solo pannello, senza l'aria.
  readonly property real panelFullW: Math.max(root.minWidth,
                                              layout.implicitWidth + Theme.spacingM * 2)
  readonly property real panelFullH: layout.implicitHeight + Theme.spacingM * 2

  // Il cassetto centrale galleggia: gli serve aria su tutti e quattro i lati.
  // Quelli a bordo occupano tutta la larghezza e ne hanno solo da un lato.
  implicitWidth:  root.panelFullW + (root.centered ? root.overshootRoom * 2 : 0)
  implicitHeight: root.panelFullH + (root.centered ? root.overshootRoom * 2
                                                   : root.overshootRoom)

  // Durata dell'entrata. Piu' lunga di durSlow: il rimbalzo ha bisogno di
  // tempo per leggersi, sotto i 250ms diventa uno scatto.
  readonly property int animDuration: 300

  // Stato locale dell'animazione. Parte false anche quando il cassetto e'
  // gia' logicamente aperto: e' l'unico modo per avere una transizione
  // invece di una comparsa secca al primo frame.
  property bool shown: false

  // 0 = pannello fuori dalla superficie, 1 = a riposo. OutBack va oltre 1.
  property real reveal: shown ? 1 : 0

  // Il rimbalzo della scala e' compresso dal fattore che lo moltiplica
  // (0.15), quindi qui serve una corsa molto piu' larga per vedersi.
  readonly property real revealOvershoot: root.centered ? 2.2 : 1.1

  Behavior on reveal {
    NumberAnimation {
      duration: root.animDuration
      easing.type: Easing.OutBack
      // Default 1.70158: troppo, servirebbe il doppio di overshootRoom.
      easing.overshoot: root.revealOvershoot
    }
  }

  // Altezza fissa, y che si muove: la parte che esce dalla superficie non
  // viene composta, ed e' li' che il pannello sparisce. Stessa formula per
  // i due bordi, cambia solo il segno. Al centro y sta ferma.
  readonly property real panelY: root.centered
      ? root.overshootRoom
      : (root.fromBottom
          ? root.overshootRoom + root.panelFullH * (1 - root.reveal)
          : root.panelFullH * (root.reveal - 1))

  readonly property real panelX: root.centered ? root.overshootRoom : 0
  readonly property real panelW: root.centered ? root.panelFullW : root.width

  // Scala e opacita' solo al centro: i cassetti a bordo restano identici
  // a prima, questi due valori li lasciano a 1.
  readonly property real panelScale:   root.centered ? 0.85 + 0.15 * root.reveal : 1.0
  // Il clamp e' esplicito anche se Qt lo farebbe: reveal supera 1 e leggere
  // "opacity: 1.15" in un log e' un falso allarme evitabile.
  readonly property real panelOpacity: root.centered ? Math.min(1, root.reveal) : 1.0

  // Intersezione fra pannello e superficie: durante il rimbalzo il
  // pannello si stacca dal bordo e la regione deve seguirlo. Al centro
  // la formula si riduce da sola al rettangolo del pannello.
  readonly property real maskY: Math.max(0, root.panelY)
  readonly property real maskH: Math.max(0,
      Math.min(root.height, root.panelY + root.panelFullH) - root.maskY)

      Component.onCompleted: {
        Drawers.registerWindow(root.name, root)
        // Rimandato di un ciclo: se lo scrivessi qui, il valore iniziale e
        // quello finale verrebbero applicati insieme e il Behavior non scatta.
        Qt.callLater(() => root.shown = true)
        // Dopo il grab: prima la superficie non ha il focus Wayland e il
        // focus Qt andrebbe perso. 80 > i 50ms di grabDelay in Drawers.
        if (root.grabKeyboard) focusTimer.restart()
      }

      Timer {
        id: focusTimer
        interval: 80
        onTriggered: root.focusReady()
      }

  Connections {
    target: Drawers
    function onCurrentChanged() {
      root.shown = Drawers.isOpen(root.name)
      if (root.shown) exitTimer.stop()
      else exitTimer.restart()
    }
  }

  // Smontaggio temporizzato invece che agganciato a onFinished del
  // Behavior: qui il momento della fine e' esplicito e verificabile.
  Timer {
    id: exitTimer
    interval: root.animDuration + 20
    onTriggered: Drawers.unload(root.name)
  }

  Rectangle {
    x: root.panelX
    y: root.panelY
    width:  root.panelW
    height: root.panelFullH

    topLeftRadius:      root.topRadius
    topRightRadius:     root.topRadius
    bottomLeftRadius:   root.bottomRadius
    bottomRightRadius:  root.bottomRadius

    color: Theme.surface
    antialiasing: true

    transformOrigin: Item.Center
    scale:   root.panelScale
    opacity: root.panelOpacity

    Behavior on color {
      ColorAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
    }

    // L'hover sta qui e non sul layout: dentro ci sono righe con i loro
    // HoverHandler, e l'auto-close non deve dipendere da chi vince.
    HoverHandler {
      onHoveredChanged: Drawers.hovered = hovered
    }
  }

  // x/y/width espliciti invece di anchors.fill: il layout determina
  // l'altezza della finestra e insieme si posiziona in base a panelY, che
  // da quell'altezza dipende. Con anchors.fill nasce un binding loop.
  ColumnLayout {
    id: layout

    x: root.panelX + Theme.spacingM
    y: root.panelY + Theme.spacingM
    width: root.panelW - Theme.spacingM * 2

    spacing: Theme.spacingXs

    // Stesso centro del rettangolo sotto, perche' l'inset e' simmetrico:
    // le due scale restano allineate senza un wrapper comune.
    transformOrigin: Item.Center
    scale:   root.panelScale
    opacity: root.panelOpacity
  }

  // Regione d'input sulla sola porzione visibile: l'aria del rimbalzo
  // resta click-through.
  mask: Region {
    x: root.panelX
    y: root.maskY
    width:  root.panelW
    height: root.maskH
  }
}
