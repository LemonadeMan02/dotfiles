// DayAgenda.qml
import QtQuick
import QtQuick.Layouts
import "../../services"


// Eventi del giorno scelto, con frecce per il giorno prima e quello dopo.
ColumnLayout {
  id: root
  spacing: Theme.spacingS

  // Il giorno lo decide Today.qml: qui si chiede solo di cambiarlo.
  required property var day
  signal picked(var day)

  readonly property var events: Events.eventsOn(root.day)

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
      text: root.day.toLocaleDateString(Qt.locale(), "dddd d MMMM")
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
    font.pixelSize: Theme.fontS
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

    delegate: Rectangle {
      id: entry
      required property var modelData

      width: ListView.view.width
      implicitHeight: body.implicitHeight + Theme.spacingM * 2
      radius: Theme.radiusS
      color: Theme.surfaceSolid

      // x/width espliciti: il Rectangle e' un delegate, non un layout.
      ColumnLayout {
        id: body
        x: Theme.spacingM
        y: Theme.spacingM
        width: entry.width - Theme.spacingM * 2
        spacing: Theme.spacingXs

        Text {
          Layout.fillWidth: true
          text: entry.modelData.allDay ? "All day" : entry.modelData.start + " – " + entry.modelData.end
          color: Theme.accent
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontS
          font.weight: Theme.weightBold
        }

        // Titoli lunghi vanno a capo: leggerli e' lo scopo del pannello.
        Text {
          Layout.fillWidth: true
          text: entry.modelData.title
          wrapMode: Text.Wrap
          color: Theme.foreground
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontM
          font.weight: Theme.weightNormal
        }
      }
    }
  }
}
