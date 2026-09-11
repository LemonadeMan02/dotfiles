// Theme.qml
pragma Singleton
import QtQuick

QtObject {
  readonly property color background: "#1e1e2e"
  readonly property color foreground: "#cdd6f4"
  readonly property color accent: "#89b4fa"

  readonly property int radius: 12
  readonly property int padding: 10
  readonly property string fontFamily: "JetBrains Mono"
  readonly property string nerdFontFamily: "JetBrainsMono Nerd Font"
}
// dentro Singleton { ... }, sotto le altre property

function iconFor(code) {
  if (code === 0) return "\uf00d";              // sereno
  if (code >= 1 && code <= 2) return "\uf002";  // poco nuvoloso
  if (code === 3) return "\uf013";              // nuvoloso
  if (code === 45 || code === 48) return "\uf014"; // nebbia
  if (code >= 51 && code <= 57) return "\uf01c"; // pioviggine
  if (code >= 61 && code <= 67) return "\uf019"; // pioggia
  if (code >= 71 && code <= 77) return "\uf01b"; // neve
  if (code >= 80 && code <= 82) return "\uf01a"; // rovesci
  if (code >= 85 && code <= 86) return "\uf01b"; // rovesci di neve
  if (code >= 95 && code <= 99) return "\uf01e"; // temporale
  return "\uf00d";
}

readonly property string icon: iconFor(weatherCode)
