// Net.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick


Singleton {
  id: root

  // L'unica cosa da configurare a mano. systemd-networkd non ha un
  // concetto di "interfaccia principale" da interrogare: lo decidi tu.
  readonly property string iface: "enp3s0"
  readonly property bool wired: true

  // "up", "down", "unknown", "dormant". Il kernel lo scrive qui.
  readonly property string operstate: {
    const t = view.text()
    return t ? t.trim() : ""
  }

  readonly property bool connected: operstate === "up"

  readonly property string label: {
    if (!connected) return "Offline"
    return wired ? "Ethernet" : iface
  }

  FileView {
    id: view
    path: "/sys/class/net/" + root.iface + "/operstate"

    // Lettura sincrona all'avvio: senza, il primo frame della barra
    // mostra "Offline" per qualche millisecondo.
    blockLoading: true

    // I file sysfs non sono file veri e inotify su di essi e' inaffidabile:
    // niente watchChanges, si rilegge a intervalli.
    printErrors: false
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: view.reload()
  }
}
