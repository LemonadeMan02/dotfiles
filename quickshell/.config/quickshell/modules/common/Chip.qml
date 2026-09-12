// Chip.qml
import QtQuick
import "../../services"


Pill {
  radius:   Theme.radiusS
  paddingH: Theme.spacingM
  paddingV: Theme.spacingXs
  spacing:  Theme.spacingS

  // Opaco sopra la pill traslucida: e' quello che lo fa leggere come
  // elemento distinto invece che come parte dello sfondo.
  bgNormal: Theme.surfaceSolid
}
