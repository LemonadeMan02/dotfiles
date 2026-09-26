// Notifications.qml
pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick


Singleton {
  id: root

  // Notifiche vive, dalla piu' vecchia alla piu' recente. Chiuse o scadute escono da sole.
  readonly property var list: server.trackedNotifications.values

  // Id delle notifiche uscite dai popup ma ancora in cronologia. Riassegnato, mai mutato.
  property var retired: ({})

  // Popup a schermo: le vive che non sono ancora state ritirate.
  readonly property var popups: root.list.filter(n => !root.retired[n.id])

  // Cronologia: le vive, tranne quelle che chiedono di non essere conservate.
  readonly property var history: root.list.filter(n => !n.transient)

  // Non disturbare: le nuove vanno dritte in cronologia. Il ?? copre la config non ancora letta.
  readonly property bool dnd: Config.notifications?.dnd ?? false

  // Durata di un popup quando l'app non la chiede, in millisecondi.
  readonly property int defaultTimeout: 5000

  // Oltre questo numero le piu' vecchie escono dalla cronologia.
  readonly property int historyLimit: 50

  // Durata in ms; 0 = resta finche' non la chiudi. E' l'urgenza a dire cosa non va perso.
  function timeoutFor(n) {
    if (n?.urgency === NotificationUrgency.Critical) return 0
    return (n?.expireTimeout ?? 0) > 0 ? n.expireTimeout * 1000 : root.defaultTimeout
  }

  // Fine del popup: la transitoria scade davvero, le altre passano in cronologia.
  function retire(n) {
    if (!n) return
    if (n.transient) {
      n.expire()
      return
    }
    const r = Object.assign({}, root.retired)
    r[n.id] = true
    root.retired = r
  }

  // Notifica chiusa per qualunque motivo: il suo id non serve piu'.
  function forget(id) {
    if (!root.retired[id]) return
    const r = Object.assign({}, root.retired)
    delete r[id]
    root.retired = r
  }

  // "Clear all" e' una chiusura dell'utente: le app lo vengono a sapere.
  function clearAll() {
    for (const n of root.history.slice()) n.dismiss()
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

  // Click su una notifica: l'azione di default se c'e', altrimenti chiusura esplicita.
  function activate(n) {
    const a = root.defaultAction(n)
    if (a) a.invoke()
    else n.dismiss()
  }

  NotificationServer {
    id: server

    // Con la cronologia un reload a caldo non deve perderla; i popup li evita lastGeneration.
    keepOnReload: true

    // Annunciati alle app: senza, molte non mandano ne' pulsanti ne' immagini.
    actionsSupported: true
    imageSupported: true

    onNotification: (n) => {
      // Senza tracked la notifica verrebbe scartata appena arrivata.
      n.tracked = true
      n.closed.connect(() => root.forget(n.id))

      // Gia' vista prima di un reload, o non disturbare attivo: niente popup.
      // Le critiche bucano il non disturbare: esistono per non essere perse.
      const critical = n.urgency === NotificationUrgency.Critical
      if (n.lastGeneration || (root.dnd && !critical)) root.retire(n)

      // Tetto alla cronologia: la piu' vecchia esce, senza disturbare l'app.
      const h = root.history
      if (h.length > root.historyLimit) h[0].expire()
    }
  }
}
