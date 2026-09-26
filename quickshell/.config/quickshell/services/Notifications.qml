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

  // Durata in ms; 0 = resta finche' non la chiudi. E' l'urgenza a dire cosa non va perso.
  function timeoutFor(n) {
    if (n?.urgency === NotificationUrgency.Critical) return 0
    return (n?.expireTimeout ?? 0) > 0 ? n.expireTimeout * 1000 : root.defaultTimeout
  }

  // Nome del tema, percorso o URL: sempre qualcosa che Image sa caricare, oppure "".
  function resolve(i) {
    if (!i) return ""
    if (i.startsWith("/")) return "file://" + i
    if (i.includes("://")) return i
    return Quickshell.iconPath(i, true)
  }

  // A sinistra l'immagine della notifica (avatar, copertina), altrimenti l'icona dell'app.
  function visualFor(n) {
    return root.resolve(n?.image || n?.appIcon || "")
  }

  // Icona piccola accanto al nome: solo se a sinistra c'e' gia' un'immagine diversa.
  function badgeFor(n) {
    return (n?.image && n?.appIcon) ? root.resolve(n.appIcon) : ""
  }

  // "default" per la specifica e' il click sulla notifica, non un pulsante.
  function defaultAction(n) {
    const acts = n?.actions ?? []
    for (let i = 0; i < acts.length; i++)
      if (acts[i].identifier === "default") return acts[i]
    return null
  }

  // Pulsanti da mostrare: tutte le azioni con un testo, tranne quella di default.
  function buttonsFor(n) {
    const acts = n?.actions ?? []
    const out = []
    for (let i = 0; i < acts.length; i++)
      if (acts[i].identifier !== "default" && acts[i].text !== "") out.push(acts[i])
    return out
  }

  // Click sulla card: l'azione di default se c'e', altrimenti chiusura esplicita.
  function activate(n) {
    const a = root.defaultAction(n)
    if (a) a.invoke()
    else n.dismiss()
  }

  NotificationServer {
    id: server

    // Un reload a caldo non deve far ricomparire tutti i popup ancora aperti.
    keepOnReload: false

    // Annunciati alle app: senza, molte non mandano ne' pulsanti ne' immagini.
    actionsSupported: true
    imageSupported: true

    // Senza tracked la notifica verrebbe scartata appena arrivata.
    onNotification: (n) => { n.tracked = true }
  }
}
