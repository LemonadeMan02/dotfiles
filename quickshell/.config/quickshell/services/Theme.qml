// Theme.qml
pragma Singleton

import QtQuick


QtObject {
  id: root

  function withAlpha(col, a) {
    return Qt.rgba(col.r, col.g, col.b, a)
  }

  // ── 1. Primitive: le due palette Catppuccin, crude ──────────────────
  // Stessi nomi in entrambe: il livello semantico resta cieco alla variante.
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
    // Non definiti da Catppuccin: valori scelti per contrasto.
    readonly property color inverseSurface:   "#cdd6f4"
    readonly property color inverseOnSurface: "#11111b"
    readonly property color onPrimary:        "#11111b" // 9.2:1 su mauve
    readonly property color onTertiary:       "#11111b" // testo su pink
    readonly property color onError:          "#11111b" // testo su red
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
    readonly property color onPrimary:        "#eff1f5" // 4.7:1 su mauve
    readonly property color onTertiary:       "#11111b" // fuori palette: nessun Latte supera 4.5:1 su pink
    readonly property color onError:          "#eff1f5" // 4.7:1 su red
  }

  // Il ?? evita che un adapter non ancora caricato diventi "tema chiaro".
  readonly property bool dark: Config.appearance?.darkMode ?? true

  // ── 1b. Palette generata ────────────────────────────────────────────
  readonly property QtObject fallback: dark ? mocha : latte

  // Oggetto JS crudo di matugen, o null. I valori sono stringhe.
  readonly property var gen: Colors.ready ? (dark ? Colors.dark : Colors.light)
                                          : null

  readonly property bool dynamic: (Config.appearance?.dynamicColors ?? true)
                                  && gen !== null

  // Ripiego per chiave: un colors.json vecchio senza un ruolo non produce undefined.
  function pick(k) {
    return (root.dynamic && root.gen[k]) ? root.gen[k] : root.fallback[k]
  }

  // Punto unico di conversione: le stringhe del JSON diventano color qui.
  readonly property QtObject c: QtObject {
    readonly property color crust:    root.pick("crust")
    readonly property color mantle:   root.pick("mantle")
    readonly property color base:     root.pick("base")
    readonly property color surface0: root.pick("surface0")
    readonly property color surface1: root.pick("surface1")
    readonly property color overlay0: root.pick("overlay0")
    readonly property color subtext0: root.pick("subtext0")
    readonly property color text:     root.pick("text")
    readonly property color blue:     root.pick("blue")
    readonly property color mauve:    root.pick("mauve")
    readonly property color pink:     root.pick("pink")
    readonly property color green:    root.pick("green")
    readonly property color yellow:   root.pick("yellow")
    readonly property color peach:    root.pick("peach")
    readonly property color red:      root.pick("red")

    readonly property color inverseSurface:   root.pick("inverseSurface")
    readonly property color inverseOnSurface: root.pick("inverseOnSurface")
    readonly property color onPrimary:        root.pick("onPrimary")
    readonly property color onTertiary:       root.pick("onTertiary")
    readonly property color onError:          root.pick("onError")
  }

  // ── 2. Semantica ────────────────────────────────────────────────────
  // Sotto ignore_alpha (0.30, layerrules.lua) Hyprland non sfoca: margine per l'antialias.
  readonly property real minPillAlpha: 0.35

  // Rimappatura, non clamp: tutta la corsa dello slider ha effetto.
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

  // Ogni superficie colorata ha il suo "on": la coppia la garantisce il generatore.
  readonly property color accent:        c.mauve
  readonly property color onAccent:      c.onPrimary
  readonly property color urgent:        c.red
  readonly property color onUrgent:      c.onError

  // Contenitori invertiti rispetto allo sfondo. Il nome "Light" e' storico.
  readonly property color surfaceLight:       c.inverseSurface
  readonly property color surfaceLightHover:  withAlpha(c.inverseSurface, 0.85)
  readonly property color onLight:            c.inverseOnSurface
  readonly property color onLightDim:         withAlpha(c.inverseOnSurface, 0.55)

  readonly property color surfaceAccent:       c.pink
  readonly property color surfaceAccentHover:  withAlpha(c.pink, 0.85)
  readonly property color onSurfaceAccent:     c.onTertiary
  readonly property color onSurfaceAccentDim:  withAlpha(c.onTertiary, 0.55)

  // ── 3. Scale ────────────────────────────────────────────────────────
  readonly property int spacingXs: 2
  readonly property int spacingS:  4
  readonly property int spacingM:  8
  readonly property int spacingL:  12

  readonly property int radiusS:    6
  readonly property int radiusM:    10
  readonly property int radiusFull: 999

  // Altezza unica delle pill della barra: dimensionata sull'orologio a due righe.
  readonly property int barHeight:  52
  // Chip interni: riempiono la pill lasciando spacingM sopra e sotto.
  readonly property int chipHeight: barHeight - spacingM * 2

  readonly property int fontXs: 11
  readonly property int fontS:  13
  readonly property int fontM:  15
  readonly property int fontL:  17
  readonly property int iconXs: 15
  readonly property int iconM:  22
  readonly property int iconL:  30

  // Peso dei caratteri: cambiando questi due cambia tutta la shell.
  readonly property int weightNormal: Font.Medium
  readonly property int weightBold:   Font.Bold

  readonly property int durFast: 120
  readonly property int durSlow: 220

  readonly property string fontFamily:     "JetBrains Mono"
  readonly property string nerdFontFamily: "JetBrainsMono Nerd Font"
}
