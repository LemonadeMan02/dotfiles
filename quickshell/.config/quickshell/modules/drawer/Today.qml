// Today.qml
import QtQuick
import QtQuick.Layouts
import "../../services"


// Pannello dell'orologio: calendario, agenda e notifiche, il meteo nel passo successivo.
ColumnLayout {
  id: root
  spacing: Theme.spacingM

  // Giorno scelto, condiviso da calendario e agenda: il cassetto nasce su oggi.
  property var selectedDay: new Date()

  // ── Calendario e agenda ─────────────────────────────────────────────
  // Entrambi riempiono: Qt divide lo spazio in proporzione ai preferredWidth (3 : 2),
  // indipendente dal contenuto, quindi la larghezza non cambia col mese.
  RowLayout {
    Layout.fillWidth: true
    spacing: Theme.spacingM

    MonthCalendar {
      Layout.fillWidth: true
      Layout.preferredWidth: 3
      selected: root.selectedDay
      onPicked: (day) => root.selectedDay = day
    }

    DayAgenda {
      Layout.fillWidth: true
      Layout.preferredWidth: 2
      Layout.fillHeight: true
      day: root.selectedDay
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
