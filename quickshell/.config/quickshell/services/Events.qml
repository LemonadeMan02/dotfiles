// Events.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Eventi di Google Calendar letti da khal; la sincronizzazione la fa vdirsyncer.timer.
Singleton {
  id: root

  // Eventi per giorno: "yyyy-MM-dd" → [{ title, start, end, allDay }]
  property var byDate: ({})

  // Primo giorno della richiesta in corso: khal stampa una riga per giorno da qui.
  property var from: new Date()

  // Richiesta arrivata mentre khal lavorava: ne resta solo l'ultima.
  property var pending: null

  readonly property bool loading: proc.running

  function key(d) { return Qt.formatDate(d, "yyyy-MM-dd") }

  function eventsOn(d) { return root.byDate[key(d)] ?? [] }

  // Intervallo di giorni, estremi inclusi; nessun polling, lo chiama chi apre il pannello.
  function load(start, end) {
    root.pending = { start: start, end: end }
    if (!proc.running) root.next()
  }

  // Non interrompe khal: l'output di un processo terminato finirebbe sui giorni sbagliati.
  function next() {
    const r = root.pending
    root.pending = null
    root.from = r.start
    proc.exec(["khal", "list",
               "--json", "title", "--json", "start-time", "--json", "end-time", "--json", "all-day",
               key(r.start), key(r.end)])
  }

  Process {
    id: proc

    stdout: StdioCollector {
      onStreamFinished: {
        const map = {}
        const lines = text.split("\n").filter(l => l !== "")
        for (let i = 0; i < lines.length; i++) {
          try {
            const events = JSON.parse(lines[i])
            if (events.length === 0) continue
            // new Date(a, m, g + i) gestisce da solo fine mese e ora legale
            const day = new Date(root.from.getFullYear(), root.from.getMonth(), root.from.getDate() + i)
            map[root.key(day)] = events.map(e => ({
              title: e.title,
              start: e["start-time"],
              end: e["end-time"],
              allDay: e["all-day"] === "True"
            }))
          } catch (err) {
            console.warn("Events: riga di khal illeggibile:", lines[i])
          }
        }
        root.byDate = map
      }
    }

    // exited arriva dopo streamFinished: a questo punto i dati sono gia' in byDate.
    onExited: (code) => {
      if (code !== 0) console.warn("Events: khal uscito con codice", code)
      if (root.pending) root.next()
    }
  }
}
