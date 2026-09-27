// TodayHeader.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../services"


// Cima del pannello: la data di oggi in grande a sinistra, a destra cosa ti aspetta oggi.
RowLayout {
  id: root
  spacing: Theme.spacingL

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  readonly property var events: Events.eventsOn(clock.date)
  readonly property string now: Qt.formatTime(clock.date, "hh:mm")

  // Primo evento non ancora finito; "hh:mm" si confronta bene anche come stringa.
  readonly property var next: root.events.find(e => !e.allDay && e.end > root.now) ?? null
  readonly property bool ongoing: root.next !== null && root.next.start <= root.now

  // Numero del giorno: la cosa piu' grande del pannello, in accento.
  Text {
    Layout.alignment: Qt.AlignVCenter
    text: clock.date.getDate()
    color: Theme.accent
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontDisplay
    font.weight: Theme.weightBold
  }

  ColumnLayout {
    Layout.alignment: Qt.AlignVCenter
    spacing: 0

    Text {
      text: clock.date.toLocaleDateString(Qt.locale(), "dddd")
      color: Theme.foreground
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontXl
      font.weight: Theme.weightBold
      font.capitalization: Font.Capitalize
    }

    Text {
      text: clock.date.toLocaleDateString(Qt.locale(), "MMMM yyyy")
      color: Theme.foregroundDim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontM
      font.weight: Theme.weightNormal
      font.capitalization: Font.Capitalize
    }
  }

  // Riassunto di oggi: prende lo spazio rimasto, testi a destra e troncati se lunghi.
  ColumnLayout {
    Layout.alignment: Qt.AlignVCenter
    Layout.fillWidth: true
    spacing: Theme.spacingXs

    Text {
      Layout.fillWidth: true
      horizontalAlignment: Text.AlignRight
      text: root.events.length === 0 ? "No events today"
          : root.events.length === 1 ? "1 event today"
          : root.events.length + " events today"
      color: root.events.length > 0 ? Theme.foreground : Theme.muted
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontL
      font.weight: Theme.weightBold
    }

    // In corso o prossimo: l'informazione da cogliere al volo, quindi in accento.
    Text {
      Layout.fillWidth: true
      visible: root.next !== null
      text: root.next ? (root.ongoing ? "Now · until " + root.next.end : "Next · " + root.next.start)
                        + "  " + root.next.title : ""
      horizontalAlignment: Text.AlignRight
      elide: Text.ElideRight
      color: Theme.accent
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontM
      font.weight: Theme.weightBold
    }
  }
}
