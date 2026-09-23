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

  // Larghezza fissa del pannello: il contenuto si adatta, il testo lungo
  // viene troncato da chi lo mostra. Un pannello che si allarga mentre
  // scrivi costringe l'occhio a inseguire il bordo.
  property int panelWidth: 400

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

  // ── Dimensioni ──────────────────────────────────────────────────────
  // Ancorato a sinistra e destra: il pannello riempie lo schermo.
  readonly property bool fullWidth: root.anchors.left && root.anchors.right
  readonly property real drawW: root.fullWidth ? root.width : root.panelWidth

  // Voluta dal contenuto: cambia di scatto a ogni riga in piu' o in meno.
  readonly property real panelFullH: layout.implicitHeight + Theme.spacingM * 2

  // Disegnata: insegue quella voluta. Il contenuto cambia subito, il fondo
  // lo raggiunge in modo fluido.
  property real panelH: panelFullH

  Behavior on panelH {
    // Spento prima dell'apertura: il layout si riempie nei primi frame e
    // non deve allungarsi sotto gli occhi.
    enabled: root.shown
    NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutCubic }
  }

  // Altezza della superficie Wayland: solo cresce finche' il cassetto e' vivo.
  // Il pannello si muove dentro; un resize per frame costerebbe un giro col
  // compositore a ogni frame.
  property real surfaceH: 0
  onPanelFullHChanged: root.surfaceH = Math.max(root.surfaceH, root.panelFullH)

  // Il cassetto centrale galleggia: gli serve aria su tutti e quattro i lati.
  // Quelli a bordo ne hanno solo da un lato.
  implicitWidth:  root.panelWidth + (root.centered ? root.overshootRoom * 2 : 0)
  implicitHeight: root.surfaceH + (root.centered ? root.overshootRoom * 2
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

  // ── Posizione del pannello nella superficie ─────────────────────────
  // In basso: incollato al fondo, esce traslando verso il basso. In alto:
  // incollato al bordo superiore. Al centro: centrato, fermo.
  readonly property real panelY: root.centered
      ? root.overshootRoom + (root.surfaceH - root.panelH) / 2
      : (root.fromBottom
          ? root.overshootRoom + root.surfaceH - root.panelH * root.reveal
          : root.panelH * (root.reveal - 1))

  readonly property real panelX: root.centered ? root.overshootRoom : 0

  // Scala e opacita' solo al centro: i cassetti a bordo le lasciano a 1.
  readonly property real panelScale:   root.centered ? 0.85 + 0.15 * root.reveal : 1.0
  // Il clamp e' esplicito anche se Qt lo farebbe: reveal supera 1 e leggere
  // "opacity: 1.15" in un log e' un falso allarme evitabile.
  readonly property real panelOpacity: root.centered ? Math.min(1, root.reveal) : 1.0

  // Intersezione fra pannello e superficie: il resto resta click-through.
  readonly property real maskY: Math.max(0, root.panelY)
  readonly property real maskH: Math.max(0,
      Math.min(root.height, root.panelY + root.panelH) - root.maskY)

  Component.onCompleted: {
    root.surfaceH = Math.max(root.surfaceH, root.panelFullH)
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
    // Solo se il timer corre: cosi' non si accende mai contro quello che dice il binding.
    function onActivity() {
      if (autoCloseTimer.running) autoCloseTimer.restart()
    }
  }

  // Smontaggio temporizzato invece che agganciato a onFinished del
  // Behavior: qui il momento della fine e' esplicito e verificabile.
  Timer {
    id: exitTimer
    interval: root.animDuration + 20
    onTriggered: Drawers.unload(root.name)
  }

  // Fermo mentre ci passi sopra; riparte da zero all'uscita e a ogni poke().
  Timer {
    id: autoCloseTimer
    interval: Drawers.autoCloseTimeout > 0 ? Drawers.autoCloseTimeout : 1000
    running: root.shown && !panelHover.hovered && Drawers.autoCloseTimeout > 0
    onTriggered: Drawers.close()
  }

  Rectangle {
    x: root.panelX
    y: root.panelY
    width:  root.drawW
    height: root.panelH

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
      id: panelHover
    }
  }

  // Stessa geometria del fondo: ritaglia il contenuto che sborda mentre
  // il fondo insegue la nuova altezza. Stesso centro, stessa scala.
  Item {
    id: body

    x: root.panelX
    y: root.panelY
    width:  root.drawW
    height: root.panelH
    clip: true

    transformOrigin: Item.Center
    scale:   root.panelScale
    opacity: root.panelOpacity

    // x/y/width espliciti invece di anchors.fill: il layout determina
    // l'altezza della finestra, e con anchors.fill nasce un binding loop.
    ColumnLayout {
      id: layout

      x: Theme.spacingM
      width: body.width - Theme.spacingM * 2

      // Dal lato del bordo: al cassetto in basso resta incollata la
      // ricerca, a quello in alto il primo blocco.
      y: root.fromBottom ? body.height - Theme.spacingM - layout.implicitHeight
       : root.centered   ? (body.height - layout.implicitHeight) / 2
                         : Theme.spacingM

      spacing: Theme.spacingXs
    }
  }

  // Regione d'input sulla sola porzione visibile: l'aria del rimbalzo e la
  // superficie in piu' restano click-through.
  mask: Region {
    x: root.panelX
    y: root.maskY
    width:  root.drawW
    height: root.maskH
  }
}
