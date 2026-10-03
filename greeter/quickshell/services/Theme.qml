// Theme.qml del greeter: sottoinsieme dei token della shell, stessi nomi
pragma Singleton

import Quickshell
import QtQuick


Singleton {
  id: root

  function withAlpha(col, a) {
    return Qt.rgba(col.r, col.g, col.b, a)
  }

  // Primitive Catppuccin Mocha; i colori di matugen arriveranno in un passo successivo
  readonly property QtObject c: QtObject {
    readonly property color crust:    "#11111b"
    readonly property color mantle:   "#181825"
    readonly property color base:     "#1e1e2e"
    readonly property color surface1: "#45475a"
    readonly property color subtext0: "#a6adc8"
    readonly property color text:     "#cdd6f4"
    readonly property color mauve:    "#cba6f7"
    readonly property color yellow:   "#f9e2af"
    readonly property color red:      "#f38ba8"
  }

  // Semantica: stessi nomi di Theme.qml della shell dove esistono
  readonly property color background:    c.base
  readonly property color surface:       c.mantle
  readonly property color foreground:    c.text
  readonly property color foregroundDim: c.subtext0
  readonly property color muted:         c.surface1
  readonly property color accent:        c.mauve
  readonly property color pending:       c.yellow
  readonly property color urgent:        c.red

  readonly property int spacingM: 8
  readonly property int spacingL: 12
  readonly property int radiusM:  10

  readonly property int fontM:     15
  // Stesse dimensioni di hyprlock.conf: lock e login devono coincidere
  readonly property int fontDate:  20
  readonly property int fontClock: 96

  readonly property int weightNormal: Font.Medium
  readonly property int weightBold:   Font.Bold

  readonly property string fontFamily: "JetBrains Mono"

  // Campo password: misure di input-field in hyprlock.conf
  readonly property int fieldWidth:  320
  readonly property int fieldHeight: 52
  readonly property int fieldBorder: 2
}
