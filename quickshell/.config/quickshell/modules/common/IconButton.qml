// IconButton.qml
import QtQuick
import "../../services"


Rectangle {
  id: root

  property string icon: ""

  // Il colore dell'hover lo decide chi istanzia: le azioni distruttive
  // usano Theme.urgent, le altre l'accento.
  property color hoverColor: Theme.accent

  // Azioni distruttive: si tiene premuto finche' il riempimento non arriva in fondo.
  property bool holdToConfirm: false
  property int holdDuration: 1000

  // Colore dell'icona sopra il riempimento: la coppia la sceglie chi istanzia.
  property color onFillColor: Theme.onAccent

  // 0 = vuoto, 1 = pieno. Lo muovono solo le due animazioni qui sotto.
  property real progress: 0

  signal activated()

  implicitWidth:  48
  implicitHeight: 40

  radius: Theme.radiusS
  antialiasing: true

  color: hover.hovered ? Theme.surfaceHover : Theme.surfaceSolid

  Behavior on color {
    ColorAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
  }

  // Riempimento da sinistra: bordo destro dritto finche' non tocca il fondo.
  Rectangle {
    width:  root.width * root.progress
    height: root.height
    visible: root.progress > 0
    color: root.hoverColor
    antialiasing: true

    topLeftRadius:     root.radius
    bottomLeftRadius:  root.radius
    topRightRadius:    root.progress >= 1 ? root.radius : 0
    bottomRightRadius: root.progress >= 1 ? root.radius : 0
  }

  Text {
    anchors.centerIn: parent
    text: root.icon
    font.family: Theme.nerdFontFamily
    font.pixelSize: Theme.iconM
    // Oltre meta' il riempimento passa sotto l'icona: serve il colore in contrasto.
    color: root.progress > 0.5 ? root.onFillColor
         : hover.hovered       ? root.hoverColor
                               : Theme.foreground

    Behavior on color {
      ColorAnimation { duration: Theme.durFast }
    }
  }

  HoverHandler {
    id: hover
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    id: tap

    // Click semplice solo senza conferma: altrimenti decide il riempimento.
    onTapped: if (!root.holdToConfirm) root.activated()

    onPressedChanged: {
      if (!root.holdToConfirm) return
      if (tap.pressed) {
        drain.stop()
        // Riparte da dove era: una pressione a meta' ritirata non ricomincia da zero.
        fill.duration = root.holdDuration * (1 - root.progress)
        fill.start()
      } else if (root.progress < 1) {
        fill.stop()
        drain.start()
      }
    }
  }

  // Durata assegnata alla pressione, non legata: cambierebbe mentre l'animazione corre.
  NumberAnimation {
    id: fill
    target: root
    property: "progress"
    to: 1
    duration: root.holdDuration

    // La guardia copre anche lo stop(): parte solo se il pieno e' arrivato davvero in fondo.
    onFinished: {
      if (root.progress < 1) return
      // Azzerato prima di emettere: riaprendo a meta' uscita non deve scattare al primo tocco.
      root.progress = 0
      root.activated()
    }
  }

  // Rilascio prima della fine: il riempimento si ritira, piu' in fretta di come e' salito.
  NumberAnimation {
    id: drain
    target: root
    property: "progress"
    to: 0
    duration: Theme.durSlow
    easing.type: Easing.OutCubic
  }
}
