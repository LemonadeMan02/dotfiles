// Theme.qml
pragma Singleton

import QtQuick


QtObject {
  readonly property color background: "#1e1e2e"
  readonly property color surface:    "#313244"
  readonly property color foreground: "#cdd6f4"
  readonly property color muted:      "#6c7086"
  readonly property color accent:     "#89b4fa"

  readonly property int radius: 12
  readonly property int padding: 10
  readonly property string fontFamily: "JetBrains Mono"
  readonly property string nerdFontFamily: "JetBrainsMono Nerd Font"
}
