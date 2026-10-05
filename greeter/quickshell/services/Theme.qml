// Theme.qml del greeter: sottoinsieme dei token della shell, stessi nomi
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick


Singleton {
  id: root

  function withAlpha(col, a) {
    return Qt.rgba(col.r, col.g, col.b, a)
  }

  // Copie lasciate da greeter-sync (scripts/): l'utente greeter non legge la home
  readonly property string sharedDir: "/var/lib/greeter-theme"
  readonly property string wallpaperUrl: "file://" + sharedDir + "/wallpaper"

  // Primitive Catppuccin Mocha: ripiego finche' greeter-sync non ha copiato colors.json
  readonly property QtObject mocha: QtObject {
    readonly property color crust:     "#11111b"
    readonly property color mantle:    "#181825"
    readonly property color base:      "#1e1e2e"
    readonly property color surface0:  "#313244"
    readonly property color surface1:  "#45475a"
    readonly property color subtext0:  "#a6adc8"
    readonly property color text:      "#cdd6f4"
    readonly property color mauve:     "#cba6f7"
    readonly property color yellow:    "#f9e2af"
    readonly property color red:       "#f38ba8"
    readonly property color onPrimary: "#11111b"
    readonly property color onError:   "#11111b"
  }

  // Sempre la variante scura, anche col tema chiaro nella sessione: il testo
  // sta sopra lo sfondo scurito e deve restare chiaro
  readonly property var gen: {
    const t = colorsView.text()
    if (!t) return null
    try {
      return JSON.parse(t).dark ?? null
    } catch (e) {
      return null
    }
  }

  // Ripiego per chiave, come nella shell: un colors.json vecchio senza un ruolo non da' undefined
  function pick(k) {
    return (root.gen && root.gen[k]) ? root.gen[k] : root.mocha[k]
  }

  readonly property QtObject c: QtObject {
    readonly property color crust:     root.pick("crust")
    readonly property color mantle:    root.pick("mantle")
    readonly property color base:      root.pick("base")
    readonly property color surface0:  root.pick("surface0")
    readonly property color surface1:  root.pick("surface1")
    readonly property color subtext0:  root.pick("subtext0")
    readonly property color text:      root.pick("text")
    readonly property color mauve:     root.pick("mauve")
    readonly property color yellow:    root.pick("yellow")
    readonly property color red:       root.pick("red")
    readonly property color onPrimary: root.pick("onPrimary")
    readonly property color onError:   root.pick("onError")
  }

  // Semantica: stessi nomi di Theme.qml della shell dove esistono
  readonly property color background:    c.base
  readonly property color surface:       c.mantle
  readonly property color surfaceSolid:  c.surface0
  readonly property color surfaceHover:  withAlpha(c.surface0, 0.85)
  readonly property color foreground:    c.text
  readonly property color foregroundDim: c.subtext0
  readonly property color muted:         c.surface1
  readonly property color accent:        c.mauve
  readonly property color onAccent:      c.onPrimary
  readonly property color pending:       c.yellow
  readonly property color urgent:        c.red
  readonly property color onUrgent:      c.onError

  // Velo sullo sfondo: nero come nella shell, 0.4 = brightness 0.6 di hyprlock
  readonly property color scrim:        "#000000"
  readonly property real  scrimOpacity: 0.4

  readonly property int spacingM: 8
  readonly property int spacingL: 12
  readonly property int radiusS:  6
  readonly property int radiusM:  10

  readonly property int fontM:     15
  // Stesse dimensioni di hyprlock.conf: lock e login devono coincidere
  readonly property int fontDate:  20
  readonly property int fontClock: 96
  readonly property int iconM:     22

  readonly property int weightNormal: Font.Medium
  readonly property int weightBold:   Font.Bold

  readonly property int durFast: 120
  readonly property int durSlow: 220
  // Uscita al login: il greeter sfuma nel nero prima di lanciare la sessione
  readonly property int durLeave: 450

  readonly property string fontFamily:     "JetBrains Mono"
  readonly property string nerdFontFamily: "JetBrainsMono Nerd Font"

  // Campo password: misure di input-field in hyprlock.conf
  readonly property int fieldWidth:  320
  readonly property int fieldHeight: 52
  readonly property int fieldBorder: 2

  FileView {
    id: colorsView
    path: root.sharedDir + "/colors.json"
    // Lettura sincrona: il primo frame nasce gia' coi colori giusti
    blockLoading: true
    // File assente = colori dinamici spenti o greeter-sync mai lanciato
    printErrors: false
  }
}
