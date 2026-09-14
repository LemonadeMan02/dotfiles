// Theme.qml
pragma Singleton

import QtQuick


QtObject {
  id: root

  function withAlpha(col, a) {
    return Qt.rgba(col.r, col.g, col.b, a)
  }

  // ── 1. Primitive: le due palette Catppuccin, crude ──────────────────
  // Devono esporre esattamente gli stessi nomi: e' quello che permette
  // al livello semantico qui sotto di restare cieco alla variante.
  readonly property QtObject mocha: QtObject {
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
    readonly property color pink:     "#f5c2e7"
    readonly property color green:    "#a6e3a1"
    readonly property color yellow:   "#f9e2af"
    readonly property color peach:    "#fab387"
    readonly property color red:      "#f38ba8"
  }

  readonly property QtObject latte: QtObject {
    readonly property color crust:    "#dce0e8"
    readonly property color mantle:   "#e6e9ef"
    readonly property color base:     "#eff1f5"
    readonly property color surface0: "#ccd0da"
    readonly property color surface1: "#bcc0cc"
    readonly property color overlay0: "#9ca0b0"
    readonly property color subtext0: "#6c6f85"
    readonly property color text:     "#4c4f69"
    readonly property color blue:     "#1e66f5"
    readonly property color mauve:    "#8839ef"
    readonly property color pink:     "#ea76cb"
    readonly property color green:    "#40a02b"
    readonly property color yellow:   "#df8e1d"
    readonly property color peach:    "#fe640b"
    readonly property color red:      "#d20f39"
  }

  // Il ?? serve: all'avvio Config puo' non avere ancora caricato l'adapter,
  // e un undefined qui diventerebbe silenziosamente "tema chiaro".
  readonly property bool dark: Config.appearance?.darkMode ?? true

  readonly property QtObject c: dark ? mocha : latte

  // ── 2. Semantica ────────────────────────────────────────────────────
  // Sotto questa soglia Hyprland smette di sfocare: vedi ignore_alpha
  // (0.30) in layerrules.lua. Il margine copre l'antialias degli angoli.
  readonly property real minPillAlpha: 0.35

  // Rimappatura, non clamp: tutta la corsa dello slider produce un
  // effetto visibile, e il fondo scala non spegne mai il blur.
  readonly property real pillAlpha: {
    const t = Math.max(0, Math.min(1, Config.appearance?.transparency ?? 0.30))
    return 1.0 - t * (1.0 - root.minPillAlpha)
  }

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

  // Contenitori invertiti rispetto allo sfondo: chiari su tema scuro,
  // scuri su tema chiaro. Il nome "Light" resta storico, il contrasto
  // regge in entrambe le varianti perche' text e crust sono gli estremi.
  readonly property color surfaceLight:       c.text
  readonly property color surfaceLightHover:  withAlpha(c.text, 0.85)
  readonly property color surfaceAccent:      c.pink
  readonly property color surfaceAccentHover: withAlpha(c.pink, 0.85)
  readonly property color onLight:            c.crust
  readonly property color onLightDim:         withAlpha(c.crust, 0.55)

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
