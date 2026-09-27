// Today.qml
import QtQuick
import QtQuick.Layouts
import "../../services"


// Pannello dell'orologio: notifiche ora, calendario e meteo nei passi successivi.
ColumnLayout {
  id: root
  spacing: Theme.spacingM

  // ── Notifiche ───────────────────────────────────────────────────────
  NotificationHistory {
    Layout.fillWidth: true
  }
}
