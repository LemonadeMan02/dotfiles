// Bar.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../.."

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData
      screen: modelData

      color: "transparent"

      anchors {
        top: true
        left: true
        right: true
      }

      margins {
        top: 10
      }

      implicitHeight: 30

      // --- Gruppo sinistro: workspaces + media ---
      RowLayout {
        id: leftGroup
        spacing: 8

        anchors {
          left: parent.left
          verticalCenter: parent.verticalCenter
          leftMargin: 10
        }

        Pill {
          WorkspacesWidget {}
        }

        Pill {
          // La pill sparisce del tutto quando non c'è nessun player MPRIS,
          // così non resta un blocchetto vuoto accanto ai workspace.
          visible: media.player !== null
          MediaWidget { id: media }
        }
      }

      // --- Gruppo centrale: orologio + meteo ---
      Pill {
        anchors.centerIn: parent
        ClockWidget {}
        WeatherWidget {}
      }
    }
  }
}
