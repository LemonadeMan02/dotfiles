// TodayCard.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../services"
import "../common"


// Impegni di oggi accanto alla scheda di sblocco: stessa superficie, solo lettura.
Rectangle {
  id: root

  radius: Theme.radiusM
  antialiasing: true
  color: Theme.surface
  border.color: Theme.border

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  readonly property var events: Events.eventsOn(clock.date)
  readonly property string now: Qt.formatTime(clock.date, "hh:mm")
  readonly property string day: clock.date.toDateString()

  // Il lock puo' restare su per ore: khal si rilegge con il ritmo di vdirsyncer.timer
  // (15 minuti) e al cambio di giorno. Con due monitor le richieste sono due:
  // Events le mette in coda, e khal su un giorno solo costa poco.
  function reload() { Events.load(clock.date, clock.date) }
  onDayChanged: root.reload()

  // A colpo d'occhio serve cosa viene dopo: la lista parte dal primo evento con
  // orario non ancora finito. ListView non scorre oltre la fine, quindi se sotto
  // c'e' poco restano in vista anche quelli prima.
  function showCurrent() {
    const i = root.events.findIndex(e => !e.allDay && e.end > root.now)
    if (i >= 0) list.positionViewAtIndex(i, ListView.Beginning)
  }
  onNowChanged: root.showCurrent()

  Timer {
    interval: 15 * 60 * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.reload()
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Theme.spacingL * 2
    spacing: Theme.spacingM

    // Il conteggio dice quanti sono anche quando non stanno tutti nella scheda.
    RowLayout {
      Layout.fillWidth: true
      spacing: Theme.spacingM

      Text {
        Layout.fillWidth: true
        text: "Today"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontL
        font.weight: Theme.weightBold
      }

      Text {
        visible: root.events.length > 0
        text: root.events.length === 1 ? "1 event" : root.events.length + " events"
        color: Theme.foregroundDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontM
        font.weight: Theme.weightNormal
      }
    }

    // Giorno libero: un messaggio al posto della lista vuota. Niente "Loading…"
    // come nel drawer: qui comparirebbe per un attimo a ogni rilettura.
    Text {
      visible: root.events.length === 0
      Layout.fillWidth: true
      Layout.fillHeight: true
      text: "No events today"
      color: Theme.muted
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontM
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }

    // Alta quanto la scheda di sblocco: gli eventi in piu' si scorrono con la rotella.
    ListView {
      id: list
      visible: root.events.length > 0
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      spacing: Theme.spacingS
      model: root.events

      // callLater: i delegate del nuovo modello non esistono ancora.
      onCountChanged: Qt.callLater(root.showCurrent)

      delegate: EventEntry {
        required property var modelData
        width: ListView.view.width
        event: modelData
        isToday: true
        now: root.now
      }
    }
  }
}
