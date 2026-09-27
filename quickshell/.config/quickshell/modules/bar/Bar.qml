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

      // Namespace layer-shell: e' l'aggancio con cui Hyprland applica il blur.
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

      // Altezza dal token, non dal contenuto: identica su entrambi i monitor.
      implicitHeight: Theme.barHeight + panel.barPadding * 2

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
          fixedHeight: Theme.barHeight
          WorkspacesWidget { screen: panel.screen }
        }

        Pill {
          id: mediaPill
          fixedHeight: Theme.barHeight

          // Dissolvenza; visible legato all'opacity toglie la pill dal layout a fine animazione.
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
        fixedHeight: Theme.barHeight
        anchors.centerIn: parent
        spacing: Theme.spacingL
        interactive: true

        // Stesso schema della pill destra: lo schermo e' quello della barra cliccata.
        onClicked: Drawers.toggle("today", panel.screen)

        ClockWidget {}

        // Il meteo apre la sua pagina: il suo tap vince su quello della pill.
        WeatherWidget {
          onClicked: Drawers.toggle("weather", panel.screen)
        }
      }

      // --- Gruppo destro: indicatori di sistema ---
      RowLayout {
        id: rightGroup
        spacing: Theme.spacingM

        anchors {
          right: parent.right
          verticalCenter: parent.verticalCenter
          rightMargin: 10
        }

        // Tray in pill propria: i suoi click non devono aprire il dashboard.
        Pill {
          fixedHeight: Theme.barHeight
          paddingH: Theme.spacingS
          visible: tray.count > 0

          TrayWidget {
            id: tray
            window: panel
          }
        }

        Pill {
          fixedHeight: Theme.barHeight
          spacing: Theme.spacingS
          interactive: true

          // screen esplicito: su layer-shell il focusedMonitor puo' non seguire il mouse.
          onClicked: Drawers.toggle("dashboard", panel.screen)

          // Nascosto finche' la prima lettura non arriva: niente chip vuoto all'avvio.
          Chip {
            id: kbChip
            variant: "solid"
            visible: Kb.code !== ""

            KeyboardWidget {
              fgNormal: kbChip.foreground
              fgMuted:  kbChip.foregroundDim
            }
          }

          Chip {
            id: netChip
            variant: "light"

            NetworkWidget {
              fgNormal: netChip.foreground
              fgMuted:  netChip.foregroundDim
            }
          }

          // Solo con un dispositivo connesso: niente chip vuoto a cuffie spente.
          Chip {
            id: btChip
            variant: "light"
            visible: Bt.connected

            BluetoothWidget {
              fgNormal: btChip.foreground
              fgMuted:  btChip.foregroundDim
            }
          }

          Chip {
            id: volChip
            variant: "accent"
            interactive: true

            VolumeWidget {
              fgNormal: volChip.foreground
              fgMuted:  volChip.foregroundDim
            }
          }

          Chip {
            id: powerChip
            variant: "accent"
            interactive: true

            PowerWidget {
              fgNormal: powerChip.foreground
              fgMuted:  powerChip.foregroundDim
            }
          }
        }
      }
    }
  }
}
