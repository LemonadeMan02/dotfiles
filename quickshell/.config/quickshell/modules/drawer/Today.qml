// Today.qml
import QtQuick
import QtQuick.Layouts
import "../../services"


// Pannello dell'orologio: calendario e notifiche, il meteo nel passo successivo.
ColumnLayout {
  id: root
  spacing: Theme.spacingM

  // ── Calendario ──────────────────────────────────────────────────────
  MonthCalendar {
    Layout.fillWidth: true
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
