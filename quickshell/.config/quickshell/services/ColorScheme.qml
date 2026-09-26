// ColorScheme.qml
pragma Singleton

import Quickshell
import QtQuick


Singleton {
  id: root

  // Preferenza freedesktop: la leggono Firefox, GTK4 ed Electron tramite xdg-desktop-portal-gtk.
  readonly property string value: (Config.appearance?.darkMode ?? true) ? "prefer-dark" : "prefer-light"

  // Idempotente: chiamata anche all'avvio da shell.qml, riallinea se qualcuno l'ha cambiata da fuori.
  function sync() {
    Quickshell.execDetached(["gsettings", "set", "org.gnome.desktop.interface",
                             "color-scheme", root.value])
  }

  onValueChanged: root.sync()
}
