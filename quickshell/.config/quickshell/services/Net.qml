// Net.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick


Singleton {
  id: root

  // Interfaccia della route IPv4 di default, da /proc/net/route: Destination
  // 00000000; con piu' route di default vince la Metric piu' bassa.
  // Nessuna route di default = "" = Offline.
  readonly property string iface: {
    const t = routeView.text()
    if (!t) return ""
    let best = ""
    let bestMetric = Infinity
    // Colonne: Iface, Destination, Gateway, Flags, RefCnt, Use, Metric, ...
    for (const line of t.split("\n").slice(1)) {
      const f = line.trim().split(/\s+/)
      if (f.length < 7 || f[1] !== "00000000") continue
      const metric = parseInt(f[6], 10)
      if (metric < bestMetric) {
        best = f[0]
        bestMetric = metric
      }
    }
    return best
  }

  // Wi-Fi se il kernel la dichiara wlan; tutto il resto conta come cavo.
  readonly property bool wired: !/^DEVTYPE=wlan$/m.test(ueventView.text() ?? "")

  // "up", "down", "unknown", "dormant". Il kernel lo scrive qui.
  readonly property string operstate: {
    const t = view.text()
    return t ? t.trim() : ""
  }

  readonly property bool connected: iface !== "" && operstate === "up"

  readonly property string label: {
    if (!connected) return "Offline"
    return wired ? "Ethernet" : iface
  }

  FileView {
    id: routeView
    path: "/proc/net/route"

    // Come sotto: /proc non notifica le modifiche, si rilegge col Timer.
    blockLoading: true
    printErrors: false
  }

  FileView {
    id: ueventView
    // Senza interfaccia niente path: non cercare /sys/class/net//uevent
    path: root.iface ? "/sys/class/net/" + root.iface + "/uevent" : ""
    blockLoading: true
    printErrors: false
  }

  FileView {
    id: view
    path: root.iface ? "/sys/class/net/" + root.iface + "/operstate" : ""

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
    onTriggered: {
      // Prima la route: se cambia l'interfaccia cambiano anche i path sotto
      routeView.reload()
      ueventView.reload()
      view.reload()
    }
  }
}
