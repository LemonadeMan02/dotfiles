// Bar.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../common"
import "../../services"

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData
      screen: modelData

      // Nome del layer-shell: e' l'aggancio con cui Hyprland ci trova
      // per applicare il blur.
      WlrLayershell.namespace: "quickshell:bar"

      readonly property int barPadding: 4

      color: "transparent"

      anchors {
        top: true
        left: true
        right: true
      }

      margins {
        top: 10
      }

      implicitHeight: Math.max(leftGroup.implicitHeight, centerPill.implicitHeight)
                      + panel.barPadding * 2

      // --- Gruppo sinistro: workspaces + media ---
      RowLayout {
        id: leftGroup
        spacing: Theme.spacingM

        anchors {
          left: parent.left
          verticalCenter: parent.verticalCenter
          leftMargin: 10
        }

        Pill {
          WorkspacesWidget { screen: panel.screen }
        }

        Pill {
          id: mediaPill

          // Dissolvenza invece di comparsa secca quando apri o chiudi
          // Spotify. Il visible legato all'opacity toglie la pill dal
          // layout a fine animazione, altrimenti resta un buco.
          opacity: media.player !== null ? 1 : 0
          visible: opacity > 0

          Behavior on opacity {
            NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutCubic }
          }

          MediaWidget { id: media }
        }
      }

      // --- Gruppo centrale: orologio + meteo ---
      Pill {
        id: centerPill
        anchors.centerIn: parent
        spacing: Theme.spacingL
        ClockWidget {}
        WeatherWidget {}
      }
    }
  }
}
