// Apps.qml
pragma Singleton

import Quickshell
import QtQuick


Singleton {
  id: root

  // Subsequence fuzzy: le lettere della query devono comparire in ordine,
  // non per forza adiacenti. "frfx" trova Firefox.
  // Ritorna -1 se non c'e' match, altrimenti un punteggio: piu' alto = meglio.
  function score(text, query) {
    if (query === "") return 0

    const t = text.toLowerCase()
    const q = query.toLowerCase()

    let ti = 0
    let points = 0
    let streak = 0

    for (let qi = 0; qi < q.length; qi++) {
      const c = q[qi]
      let found = -1

      while (ti < t.length) {
        if (t[ti] === c) { found = ti; break }
        ti++
      }

      if (found === -1) return -1

      // Inizio parola: e' il segnale piu' forte che l'utente stia
      // abbreviando, quindi pesa piu' di tutto il resto.
      const atWordStart = found === 0 || t[found - 1] === " " || t[found - 1] === "-"
      if (atWordStart) points += 10

      // Lettere consecutive: premio crescente, cosi' "fire" batte "frie".
      streak = (found === ti && qi > 0) ? streak + 1 : 0
      points += streak * 3

      // Piu' avanti nel testo, meno vale.
      points += Math.max(0, 5 - found)

      ti = found + 1
    }

    return points
  }

  // Lista ordinata di DesktopEntry. Query vuota: tutto, in ordine alfabetico.
  function search(query) {
    const out = []

    for (const entry of DesktopEntries.applications.values) {
      // Rispetta NoDisplay dei .desktop: sono voci che l'ambiente non
      // deve mostrare, tipicamente handler di protocolli.
      if (entry.noDisplay) continue

      const s = root.score(entry.name, query)
      if (s < 0) continue
      out.push({ entry: entry, score: s })
    }

    out.sort((a, b) => {
      if (b.score !== a.score) return b.score - a.score
      return a.entry.name.localeCompare(b.entry.name)
    })

    return out.map(x => x.entry)
  }

  function launch(entry) {
    if (entry) entry.execute()
  }

  // DesktopEntry.icon e' un nome (es. "firefox"), non un percorso:
  // va risolto contro il tema icone installato.
  function iconFor(entry) {
    if (!entry || !entry.icon) return ""
    return Quickshell.iconPath(entry.icon, true)
  }
}
