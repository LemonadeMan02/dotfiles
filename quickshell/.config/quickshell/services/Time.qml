// Time.qml
pragma Singleton

import Quickshell
import QtQuick


Singleton {
  id: root

  // Senza secondi: meno rumore visivo nella barra.
  readonly property string time: Qt.formatDateTime(clock.date, "hh:mm")
  readonly property string date: Qt.formatDateTime(clock.date, "dddd, MMM dd")

  SystemClock {
    id: clock
    // Un risveglio al minuto invece che al secondo.
    precision: SystemClock.Minutes
  }
}
