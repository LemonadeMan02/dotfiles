// Today.qml
import QtQuick
import QtQuick.Layouts
import "../../services"


// Pannello dell'orologio: agenda, calendario e notifiche, il meteo nel passo successivo.
ColumnLayout {
  id: root
  spacing: Theme.spacingM

  // Giorno scelto, condiviso da agenda e calendario: il cassetto nasce su oggi.
  property var selectedDay: new Date()

  // ── Agenda e calendario ─────────────────────────────────────────────
  RowLayout {
    Layout.fillWidth: true
    spacing: Theme.spacingM

    // Due quinti all'elenco, il resto alla griglia.
    DayAgenda {
      Layout.preferredWidth: (root.width - Theme.spacingM) * 2 / 5
      Layout.fillHeight: true
      day: root.selectedDay
      onPicked: (day) => root.selectedDay = day
    }

    MonthCalendar {
      Layout.fillWidth: true
      selected: root.selectedDay
      onPicked: (day) => root.selectedDay = day
    }
  }

  Rectangle {
    Layout.fillWidth: true
    Layout.leftMargin:  Theme.spacingS
    Layout.rightMargin: Theme.spacingS
    implicitHeight: 1
    color: Theme.border
  }

  // ── Notifiche ───────────────────────────────────────────────────────
  NotificationHistory {
    Layout.fillWidth: true
  }
}
