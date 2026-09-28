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

  // False: il contenuto galleggia sul desktop, senza il fondo del cassetto.
  property bool showBackground: true

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

  // Rimbalzo solo per i cassetti a bordo: li' si legge come un cassetto che
  // arriva a fine corsa. Al centro si scala un pannello grande, e sforare lo
  // fa sembrare un giocattolo: meglio una frenata morbida.
  readonly property bool bounce: !root.centered

  // Aria oltre la quota di riposo, per il rimbalzo della traslazione.
  readonly property int overshootRoom: root.bounce ? 28 : 0

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

  // Aria solo dal lato del rimbalzo; il centrale non sfora e non ne ha.
  implicitWidth:  root.panelWidth
  implicitHeight: root.surfaceH + root.overshootRoom

  // Durata dell'entrata. Piu' lunga di durSlow: il rimbalzo ha bisogno di
  // tempo per leggersi, sotto i 250ms diventa uno scatto.
  readonly property int animDuration: 300

  // Stato locale dell'animazione. Parte false anche quando il cassetto e'
  // gia' logicamente aperto: e' l'unico modo per avere una transizione
  // invece di una comparsa secca al primo frame.
  property bool shown: false

  // 0 = pannello fuori dalla superficie, 1 = a riposo. OutBack va oltre 1.
  property real reveal: shown ? 1 : 0

  Behavior on reveal {
    NumberAnimation {
      duration: root.animDuration
      easing.type: root.bounce ? Easing.OutBack : Easing.OutQuint
      // Default 1.70158: troppo, servirebbe il doppio di overshootRoom.
      easing.overshoot: 1.1
    }
  }

  // ── Posizione del pannello nella superficie ─────────────────────────
  // In basso: incollato al fondo, esce traslando verso il basso. In alto:
  // incollato al bordo superiore. Al centro: centrato, fermo.
  readonly property real panelY: root.centered
      ? (root.surfaceH - root.panelH) / 2
      : (root.fromBottom
          ? root.overshootRoom + root.surfaceH - root.panelH * root.reveal
          : root.panelH * (root.reveal - 1))

  // Scala e opacita' solo al centro: i cassetti a bordo le lasciano a 1.
  // Parte da vicino: senza rimbalzo basta un accenno di zoom per dare la direzione.
  readonly property real panelScale:   root.centered ? 0.92 + 0.08 * root.reveal : 1.0
  readonly property real panelOpacity: root.centered ? root.reveal : 1.0

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
    y: root.panelY
    width:  root.drawW
    height: root.panelH

    topLeftRadius:      root.topRadius
    topRightRadius:     root.topRadius
    bottomLeftRadius:   root.bottomRadius
    bottomRightRadius:  root.bottomRadius

    // Trasparente e non invisibile: un item nascosto spegnerebbe panelHover e l'auto-close.
    color: root.showBackground ? Theme.surface : "transparent"
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
    y: root.maskY
    width:  root.drawW
    height: root.maskH
  }
}
