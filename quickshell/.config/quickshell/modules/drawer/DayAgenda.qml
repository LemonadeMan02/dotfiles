// DayAgenda.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../services"
import "../common"


// Eventi del giorno scelto, con frecce per il giorno prima e quello dopo.
ColumnLayout {
  id: root
  spacing: Theme.spacingS

  // Il giorno lo decide Today.qml: qui si chiede solo di cambiarlo.
  required property var day
  signal picked(var day)

  readonly property var events: Events.eventsOn(root.day)

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  // Solo sul giorno di oggi ha senso dire "passato" o "in corso".
  readonly property bool isToday: root.day.toDateString() === clock.date.toDateString()
  readonly property string now: Qt.formatTime(clock.date, "hh:mm")

  function step(n) {
    root.picked(new Date(root.day.getFullYear(), root.day.getMonth(), root.day.getDate() + n))
    Drawers.poke()
  }

  // Intestazione: giorno della settimana, data, frecce.
  RowLayout {
    Layout.fillWidth: true
    Layout.leftMargin:  Theme.spacingS
    Layout.rightMargin: Theme.spacingS
    spacing: Theme.spacingM

    // Click sulla data: torna a oggi.
    Text {
      Layout.fillWidth: true
      text: root.isToday ? "Today" : root.day.toLocaleDateString(Qt.locale(), "dddd d MMMM")
      elide: Text.ElideRight
      color: titleHover.hovered ? Theme.accent : Theme.foreground
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontL
      font.weight: Theme.weightBold

      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }

      HoverHandler {
        id: titleHover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        onTapped: {
          root.picked(new Date())
          Drawers.poke()
        }
      }
    }

    // Stesse frecce del calendario: qui spostano di un giorno.
    Text {
      text: "‹"
      color: prevHover.hovered ? Theme.accent : Theme.foregroundDim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontL
      font.weight: Theme.weightBold

      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }

      HoverHandler {
        id: prevHover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        onTapped: root.step(-1)
      }
    }

    Text {
      text: "›"
      color: nextHover.hovered ? Theme.accent : Theme.foregroundDim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontL
      font.weight: Theme.weightBold

      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }

      HoverHandler {
        id: nextHover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        onTapped: root.step(1)
      }
    }
  }

  // Giorno libero: un messaggio al posto della lista vuota.
  Text {
    visible: root.events.length === 0
    Layout.fillWidth: true
    Layout.fillHeight: true
    text: Events.loading ? "Loading…" : "No events"
    color: Theme.muted
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontM
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }

  // Alta quanto il calendario accanto: gli eventi in piu' si scorrono.
  ListView {
    visible: root.events.length > 0
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    spacing: Theme.spacingS
    model: root.events

    onMovementStarted: Drawers.poke()

    delegate: EventEntry {
      required property var modelData
      width: ListView.view.width
      event: modelData
      isToday: root.isToday
      now: root.now
    }
  }
}
