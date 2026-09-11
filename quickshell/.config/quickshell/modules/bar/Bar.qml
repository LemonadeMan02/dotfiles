// Bar.qml
import Quickshell
import "../.."

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      margins {
             top: 10
           }

      implicitHeight: 30

      Pill {
        anchors.centerIn: parent

        ClockWidget {}
        WeatherWidget {}
      }
    }
  }
}
