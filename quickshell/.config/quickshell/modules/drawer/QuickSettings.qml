// QuickSettings.qml
import QtQuick
import QtQuick.Layouts
import "../common"
import "../../services"


StackLayout {
  id: root

  // Stato di navigazione, non stato della shell: vive qui e muore con la
  // finestra, che LazyLoader distrugge a ogni chiusura del drawer.
  currentIndex: 0

  // ── Glifi. Incolla il carattere letterale da nerdfonts.com/cheat-sheet
  //    cercando il nome nel commento. ──────────────────────────────────
  readonly property string iconLight:   "" // nf-md-white_balance_sunny
  readonly property string iconDark:    "" // nf-md-weather_night
  readonly property string iconLock:    "" // nf-md-lock
  readonly property string iconSleep:   "" // nf-md-power_sleep
  readonly property string iconOpacity: "" // nf-md-opacity
  readonly property string iconBack:    "" // nf-md-arrow_left

  readonly property real transparency: Config.appearance?.transparency ?? 0.30

  // ── Pagina 0: elenco comandi ────────────────────────────────────────
  ColumnLayout {
    Layout.fillWidth: true
    spacing: Theme.spacingXs

    ListEntry {
      Layout.fillWidth: true
      icon: root.iconOpacity
      title: "Transparency"
      subtitle: "Change shell transparency"
      onActivated: root.currentIndex = 1
    }

    ListEntry {
      Layout.fillWidth: true
      icon: root.iconLight
      title: "Light"
      subtitle: "Change the scheme to light mode"
      onActivated: Config.setDarkMode(false)
    }

    ListEntry {
      Layout.fillWidth: true
      icon: root.iconDark
      title: "Dark"
      subtitle: "Change the scheme to dark mode"
      onActivated: Config.setDarkMode(true)
    }

    ListEntry {
      Layout.fillWidth: true
      icon: root.iconLock
      title: "Lock"
      subtitle: "Lock the current session"
      // Chiudi prima di lanciare: il focus-grab sopravvivrebbe al lock.
      onActivated: { Drawers.close(); Session.lock() }
    }

    ListEntry {
      Layout.fillWidth: true
      icon: root.iconSleep
      title: "Sleep"
      subtitle: "Suspend the system"
      onActivated: { Drawers.close(); Session.sleep() }
    }
  }

  // ── Pagina 1: trasparenza ───────────────────────────────────────────
  ColumnLayout {
    Layout.fillWidth: true
    spacing: Theme.spacingM

    ListEntry {
      Layout.fillWidth: true
      icon: root.iconBack
      title: "Transparency"
      subtitle: Math.round(root.transparency * 100) + "%"
      onActivated: root.currentIndex = 0
    }

    Slider {
      Layout.fillWidth: true
      Layout.leftMargin:   Theme.spacingL
      Layout.rightMargin:  Theme.spacingL
      Layout.bottomMargin: Theme.spacingM

      value: root.transparency
      onMoved: (v) => Config.setTransparency(v)
    }
  }
}
