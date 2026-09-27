// Bt.qml
pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
  id: root

  // Si popola in modo asincrono: all'avvio e' null, poi arriva.
  readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property bool enabled: adapter?.enabled ?? false

  // Filtro su paired, non bonded: un dispositivo connesso ma non bonded sparirebbe.
  // Ordine: prima i connessi, poi per nome.
  readonly property var paired: adapter
    ? adapter.devices.values
        .filter(d => d.paired)
        .sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
    : []

  // Fra i connessi vince l'audio: un mouse non deve rubare il chip alle cuffie.
  readonly property BluetoothDevice active: {
    const c = root.paired.filter(d => d.connected)
    return c.find(d => root.isAudio(d)) ?? c[0] ?? null
  }

  readonly property bool connected: active !== null
  readonly property string name: active?.name ?? ""
  readonly property bool hasBattery: active?.batteryAvailable ?? false
  readonly property int battery: hasBattery ? Math.round(active.battery * 100) : -1

  function isAudio(d) { return d.icon.startsWith("audio") }

  function iconFor(d) { return root.isAudio(d) ? Icons.headphones : Icons.bluetooth }

  // Uno stato di transizione visibile: l'handshake dura secondi, senza si clicca due volte.
  function statusOf(d) {
    if (d.state === BluetoothDeviceState.Connecting)    return "Connecting…"
    if (d.state === BluetoothDeviceState.Disconnecting) return "Disconnecting…"
    if (!d.connected) return "Not connected"
    return d.batteryAvailable ? "Connected · " + Math.round(d.battery * 100) + "%" : "Connected"
  }

  // Ignorato durante una transizione: un secondo click la interromperebbe a meta'.
  function toggle(d) {
    if (d.state === BluetoothDeviceState.Connecting
        || d.state === BluetoothDeviceState.Disconnecting) return
    if (d.connected) d.disconnect()
    else d.connect()
  }

  function setEnabled(on) {
    if (root.adapter) root.adapter.enabled = on
  }
}
