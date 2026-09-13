// Chip.qml
import QtQuick
import "../../services"


Pill {
  id: root

  // "solid" | "light" | "accent". Ogni variante porta la coppia sfondo +
  // primo piano: non si possono scegliere separatamente, ed e' il punto.
  property string variant: "solid"

  radius:   Theme.radiusS
  paddingH: Theme.spacingM
  paddingV: Theme.spacingXs
  spacing:  Theme.spacingS

  bgNormal: variant === "accent" ? Theme.surfaceAccent
          : variant === "light"  ? Theme.surfaceLight
          : Theme.surfaceSolid

  bgHover:  variant === "accent" ? Theme.surfaceAccentHover
          : variant === "light"  ? Theme.surfaceLightHover
          : Theme.surfaceHover

  foreground:    variant === "solid" ? Theme.foreground    : Theme.onLight
  foregroundDim: variant === "solid" ? Theme.foregroundDim : Theme.onLightDim
}
