// EventEntry.qml
import QtQuick
import QtQuick.Layouts
import "../../services"


// Un evento del calendario: orario sopra, titolo sotto. Lo usano il drawer e il lock.
Rectangle {
  id: root

  // { title, start, end, allDay } come li produce Events.
  required property var event
  // Solo sul giorno di oggi ha senso dire "passato" o "in corso".
  property bool isToday: false
  // "hh:mm": si confronta bene anche come stringa con start ed end.
  property string now: ""

  // Oggi: finito = spento, in corso = invertito. Gli altri giorni tutti normali.
  readonly property bool past: root.isToday && !root.event.allDay && root.event.end <= root.now
  readonly property bool ongoing: root.isToday && !root.event.allDay
                                  && root.event.start <= root.now && !root.past

  implicitHeight: body.implicitHeight + Theme.spacingM * 2
  radius: Theme.radiusS
  color: root.ongoing ? Theme.surfaceLight : Theme.surfaceSolid
  opacity: root.past ? 0.5 : 1

  // x/width espliciti: chi istanzia puo' essere un delegate, non un layout.
  ColumnLayout {
    id: body
    x: Theme.spacingM
    y: Theme.spacingM
    width: root.width - Theme.spacingM * 2
    spacing: Theme.spacingXs

    Text {
      Layout.fillWidth: true
      text: root.ongoing ? "Now · until " + root.event.end
          : root.event.allDay ? "All day"
          : root.event.start + " – " + root.event.end
      color: root.ongoing ? Theme.onLight : Theme.accent
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontM
      font.weight: Theme.weightBold
    }

    // Titoli lunghi vanno a capo: leggerli e' lo scopo della scheda.
    Text {
      Layout.fillWidth: true
      text: root.event.title
      wrapMode: Text.Wrap
      color: root.ongoing ? Theme.onLight : Theme.foreground
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontL
      font.weight: Theme.weightBold
    }
  }
}
