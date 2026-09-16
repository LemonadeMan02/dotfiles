// Pill.qml
import QtQuick
import QtQuick.Layouts
import "../../services"


Rectangle {
  id: root

  default property alias content: layout.data
  property alias spacing: layout.spacing

  property int paddingH: Theme.spacingL
  property int paddingV: Theme.spacingM

  // 0 = altezza dal contenuto. Un valore fisso allinea pill con contenuti diversi.
  property int fixedHeight: 0

  // Proprieta' separate: le varianti le sovrascrivono senza perdere l'hover.
  property color bgNormal: Theme.surface
  property color bgHover:  Theme.surfaceHover
  property color foreground:    Theme.foreground
  property color foregroundDim: Theme.foregroundDim

  property bool interactive: false
  readonly property bool hovered: hover.hovered

  // Emesso solo se interactive. Chi istanzia decide cosa significa.
  signal clicked()

  implicitWidth:  layout.implicitWidth + paddingH * 2
  implicitHeight: fixedHeight > 0 ? fixedHeight
                                  : layout.implicitHeight + paddingV * 2

  // Angoli arrotondati ma lati dritti: radius fisso, non height/2.
  radius: Theme.radiusM
  antialiasing: true

  color: (interactive && hovered) ? bgHover : bgNormal

  Behavior on color {
    ColorAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
  }

  HoverHandler {
    id: hover
    enabled: root.interactive
  }

  // parent esplicito: i figli vanno nel layout, ma il tap deve coprire anche il padding.
  TapHandler {
    parent: root
    enabled: root.interactive
    onTapped: root.clicked()
  }

  // centerIn: con altezza fissa il contenuto resta centrato qualunque sia la sua altezza.
  RowLayout {
    id: layout
    anchors.centerIn: parent
    spacing: Theme.spacingM
  }
}
