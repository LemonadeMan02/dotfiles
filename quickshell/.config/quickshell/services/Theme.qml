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
    // Catppuccin non li definisce: sono i valori che il contenitore
    // invertito aveva gia', promossi a nome proprio.
    readonly property color inverseSurface:   "#cdd6f4"
    readonly property color inverseOnSurface: "#11111b"
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
    readonly property color inverseSurface:   "#4c4f69"
    readonly property color inverseOnSurface: "#dce0e8"
  }

  // Il ?? serve: all'avvio Config puo' non avere ancora caricato l'adapter,
  // e un undefined qui diventerebbe silenziosamente "tema chiaro".
  readonly property bool dark: Config.appearance?.darkMode ?? true

  // ── 1b. Palette generata ────────────────────────────────────────────
  readonly property QtObject fallback: dark ? mocha : latte

  // Oggetto JS crudo di matugen, o null. I valori sono stringhe.
  readonly property var gen: Colors.ready ? (dark ? Colors.dark : Colors.light)
                                          : null

  readonly property bool dynamic: (Config.appearance?.dynamicColors ?? true)
                                  && gen !== null

  // Punto unico di conversione. Le stringhe del JSON diventano color qui,
  // cosi' withAlpha() riceve sempre un colore vero e non un testo.
  readonly property QtObject c: QtObject {
    readonly property color crust:    root.dynamic ? root.gen.crust    : root.fallback.crust
    readonly property color mantle:   root.dynamic ? root.gen.mantle   : root.fallback.mantle
    readonly property color base:     root.dynamic ? root.gen.base     : root.fallback.base
    readonly property color surface0: root.dynamic ? root.gen.surface0 : root.fallback.surface0
    readonly property color surface1: root.dynamic ? root.gen.surface1 : root.fallback.surface1
    readonly property color overlay0: root.dynamic ? root.gen.overlay0 : root.fallback.overlay0
    readonly property color subtext0: root.dynamic ? root.gen.subtext0 : root.fallback.subtext0
    readonly property color text:     root.dynamic ? root.gen.text     : root.fallback.text
    readonly property color blue:     root.dynamic ? root.gen.blue     : root.fallback.blue
    readonly property color mauve:    root.dynamic ? root.gen.mauve    : root.fallback.mauve
    readonly property color pink:     root.dynamic ? root.gen.pink     : root.fallback.pink
    readonly property color green:    root.dynamic ? root.gen.green    : root.fallback.green
    readonly property color yellow:   root.dynamic ? root.gen.yellow   : root.fallback.yellow
    readonly property color peach:    root.dynamic ? root.gen.peach    : root.fallback.peach
    readonly property color red:      root.dynamic ? root.gen.red      : root.fallback.red

    readonly property color inverseSurface:   root.dynamic ? root.gen.inverseSurface
                                                           : root.fallback.inverseSurface
    readonly property color inverseOnSurface: root.dynamic ? root.gen.inverseOnSurface
                                                           : root.fallback.inverseOnSurface
  }

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
  // scuri su tema chiaro. Il nome "Light" resta storico. Ora la coppia
  // arriva da inverseSurface/inverseOnSurface invece che dagli estremi
  // della scala: il contrasto e' garantito dal generatore, non sperato.
  readonly property color surfaceLight:       c.inverseSurface
  readonly property color surfaceLightHover:  withAlpha(c.inverseSurface, 0.85)
  readonly property color surfaceAccent:      c.pink
  readonly property color surfaceAccentHover: withAlpha(c.pink, 0.85)
  readonly property color onLight:            c.inverseOnSurface
  readonly property color onLightDim:         withAlpha(c.inverseOnSurface, 0.55)

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
