// Notifications.qml
pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick


Singleton {
  id: root

  // Notifiche vive, dalla piu' vecchia alla piu' recente. Scadute o chiuse escono da sole.
  readonly property var list: server.trackedNotifications.values

  // Durata di un popup quando l'app non la chiede, in millisecondi.
  readonly property int defaultTimeout: 5000

  // expireTimeout arriva in secondi; zero o negativo = decide il server.
  function timeoutFor(n) {
    return (n?.expireTimeout ?? 0) > 0 ? n.expireTimeout * 1000 : root.defaultTimeout
  }

  // Icona dell'app, o l'immagine della notifica se l'app manda solo quella (notify-send -i).
  // Puo' essere un nome del tema, un percorso o gia' un URL.
  function iconFor(n) {
    const i = n?.appIcon || n?.image || ""
    if (i === "") return ""
    if (i.startsWith("/")) return "file://" + i
    if (i.includes("://")) return i
    return Quickshell.iconPath(i, true)
  }

  NotificationServer {
    id: server

    // Un reload a caldo non deve far ricomparire tutti i popup ancora aperti.
    keepOnReload: false

    // Senza tracked la notifica verrebbe scartata appena arrivata.
    onNotification: (n) => { n.tracked = true }
  }
}
