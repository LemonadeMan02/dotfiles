// Theme.qml
pragma Singleton

import QtQuick


QtObject {
  id: root

  function withAlpha(col, a) {
    return Qt.rgba(col.r, col.g, col.b, a)
  }

  // ── 1. Primitive: la palette grezza (Catppuccin Mocha) ──────────────
  readonly property QtObject c: QtObject {
    readonly property color crust:    "#11111b"
    readonly property color mantle:   "#181825"
    readonly property color base:     "#1e1e2e"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color overlay0: "#6c7086"
    readonly property color subtext0: "#a6adc8"
    readonly property color text:     "#cdd6f4"
    readonly property color blue:     "#89b4fa"
    readonly property color mauve:    "#cba6f7"
    readonly property color green:    "#a6e3a1"
    readonly property color yellow:   "#f9e2af"
    readonly property color peach:    "#fab387"
    readonly property color red:      "#f38ba8"
  }

  // ── 2. Semantica ────────────────────────────────────────────────────
  readonly property real pillAlpha: 0.70

  readonly property color surface:       withAlpha(c.mantle, pillAlpha)
  readonly property color surfaceHover:  withAlpha(c.surface0, 0.85)
  readonly property color surfaceSolid:  c.surface0
  readonly property color border:        withAlpha(c.surface1, 0.50)

  readonly property color foreground:    c.text
  readonly property color foregroundDim: c.subtext0
  readonly property color muted:         c.overlay0

  readonly property color accent:        c.mauve
  readonly property color onAccent:      c.crust
  readonly property color urgent:        c.red

  readonly property color surfaceLight:   c.text     // quasi bianco, per pill informative
  readonly property color surfaceAccent:  c.red      // rosa, per pill interattive
  readonly property color onLight:        c.crust    // testo scuro su sfondo chiaro

  // ── 3. Scale ────────────────────────────────────────────────────────
  readonly property int spacingXs: 2
  readonly property int spacingS:  4
  readonly property int spacingM:  8
  readonly property int spacingL:  12

  readonly property int radiusS:    6
  readonly property int radiusM:    10
  readonly property int radiusFull: 999

  readonly property int fontXs: 11
  readonly property int fontS:  13
  readonly property int fontM:  15
  readonly property int fontL:  17
  readonly property int iconXs: 15
  readonly property int iconM:  22
  readonly property int iconL:  30


  // Peso dei caratteri. Cambiando questi due valori cambia tutta la barra.
  readonly property int weightNormal: Font.Medium
  readonly property int weightBold:   Font.Bold

  readonly property int durFast: 120
  readonly property int durSlow: 220

  readonly property string fontFamily:     "JetBrains Mono"
  readonly property string nerdFontFamily: "JetBrainsMono Nerd Font"
}
