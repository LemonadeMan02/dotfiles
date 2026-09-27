// BluetoothSection.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../common"
import "../../services"


ColumnLayout {
  id: root
  spacing: Theme.spacingXs

  // Niente adattatore, niente sezione.
  visible: Bt.adapter !== null

  // Diff invece di ricreazione: una connessione non ricostruisce le altre righe.
  ScriptModel {
    id: deviceModel
    values: Bt.enabled ? Bt.paired : []
  }

  // Intestazione: titolo e interruttore dell'adattatore.
  RowLayout {
    Layout.fillWidth: true
    Layout.leftMargin:  Theme.spacingS
    Layout.rightMargin: Theme.spacingS
    Layout.bottomMargin: Theme.spacingXs
    spacing: Theme.spacingS

    Text {
      text: "Bluetooth"
      color: Theme.foreground
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontM
      font.weight: Theme.weightBold
    }

    Item { Layout.fillWidth: true }

    Toggle {
      checked: Bt.enabled
      Layout.alignment: Qt.AlignVCenter
      onToggled: {
        Drawers.poke()
        Bt.setEnabled(!Bt.enabled)
      }
    }
  }

  Repeater {
    model: deviceModel

    delegate: ListEntry {
      required property var modelData

      Layout.fillWidth: true
      icon: Bt.iconFor(modelData)
      title: modelData.name
      subtitle: Bt.statusOf(modelData)

      onActivated: {
        Drawers.poke()
        Bt.toggle(modelData)
      }
    }
  }

  Text {
    visible: Bt.enabled && Bt.paired.length === 0
    Layout.leftMargin: Theme.spacingS
    text: "No paired devices"
    color: Theme.muted
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontS
    font.weight: Theme.weightNormal
  }
}
