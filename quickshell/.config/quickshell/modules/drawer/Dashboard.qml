// Dashboard.qml
import QtQuick
import QtQuick.Layouts
import "../common"
import "../../services"


ColumnLayout {
  id: root
  spacing: Theme.spacingM

  // ── Volume generale ─────────────────────────────────────────────────
  RowLayout {
    Layout.fillWidth: true
    Layout.leftMargin:  Theme.spacingS
    Layout.rightMargin: Theme.spacingS
    spacing: Theme.spacingM

    Text {
      text: Audio.icon
      font.family: Theme.nerdFontFamily
      font.pixelSize: Theme.iconM
      color: Audio.muted ? Theme.muted : Theme.foreground
      horizontalAlignment: Text.AlignHCenter
      // Larghezza fissa: senza, il cambio di glifo sposta lo slider.
      Layout.preferredWidth: Theme.iconL
      Layout.alignment: Qt.AlignVCenter

      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }

      HoverHandler {
        cursorShape: Qt.PointingHandCursor
      }

      // Il mute vive qui: nella barra il tap ora apre questo pannello.
      TapHandler {
        onTapped: Audio.toggleMute()
      }
    }

    Slider {
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter

      value: Audio.volume
      onMoved: (v) => Audio.setVolume(v)
    }

    Text {
      text: Audio.percent + "%"
      color: Theme.foreground
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontM
      font.weight: Theme.weightBold
      horizontalAlignment: Text.AlignRight
      // Larghezza fissa: senza, lo slider respira fra 9, 10 e 100.
      Layout.preferredWidth: 44
      Layout.alignment: Qt.AlignVCenter
    }
  }

  // Compare e sparisce col blocco che separa.
  Rectangle {
    visible: Audio.streams.length > 0
    Layout.fillWidth: true
    Layout.leftMargin:  Theme.spacingS
    Layout.rightMargin: Theme.spacingS
    implicitHeight: 1
    color: Theme.border
  }

  // ── Volume per applicazione ─────────────────────────────────────────
  AppVolume {
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

  Rectangle {
    Layout.fillWidth: true
    Layout.leftMargin:  Theme.spacingS
    Layout.rightMargin: Theme.spacingS
    implicitHeight: 1
    color: Theme.border
  }

  // ── Sessione ────────────────────────────────────────────────────────
  RowLayout {
    Layout.fillWidth: true
    Layout.leftMargin:  Theme.spacingS
    Layout.rightMargin: Theme.spacingS
    spacing: Theme.spacingM

    IconButton {
      Layout.fillWidth: true
      icon: Icons.sleep
      // Non distruttivo: click singolo. Chiudi prima: il focus-grab sopravvivrebbe al suspend.
      onActivated: { Drawers.close(); Session.sleep() }
    }

    IconButton {
      Layout.fillWidth: true
      icon: Icons.restart
      holdToConfirm: true
      onActivated: { Drawers.close(); Session.reboot() }
    }

    IconButton {
      Layout.fillWidth: true
      icon: Icons.shutdown
      holdToConfirm: true
      // Azione distruttiva: e' l'unico caso in cui urgent non significa errore.
      hoverColor: Theme.urgent
      onFillColor: Theme.onUrgent
      onActivated: { Drawers.close(); Session.shutdown() }
    }
  }
}
