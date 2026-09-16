// Chip.qml
import QtQuick
import "../../services"


Pill {
  id: root

  // "solid" | "light" | "accent": ogni variante porta la sua coppia sfondo + testo.
  property string variant: "solid"

  radius:   Theme.radiusS
  paddingH: Theme.spacingM
  paddingV: Theme.spacingXs
  spacing:  Theme.spacingS

  // Riempie la pill della barra: niente chip bassi che galleggiano nel vuoto.
  fixedHeight: Theme.chipHeight

  bgNormal: variant === "accent" ? Theme.surfaceAccent
          : variant === "light"  ? Theme.surfaceLight
          : Theme.surfaceSolid

  bgHover:  variant === "accent" ? Theme.surfaceAccentHover
          : variant === "light"  ? Theme.surfaceLightHover
          : Theme.surfaceHover

  // Prima accent usava onLight: coppia sbagliata, invisibile solo con Catppuccin.
  foreground:    variant === "accent" ? Theme.onSurfaceAccent
               : variant === "light"  ? Theme.onLight
               : Theme.foreground

  foregroundDim: variant === "accent" ? Theme.onSurfaceAccentDim
               : variant === "light"  ? Theme.onLightDim
               : Theme.foregroundDim
}
