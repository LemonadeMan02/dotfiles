// Colors.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick


Singleton {
  id: root

  // Dato generato, sola lettura. Sta fuori da Config di proposito: quello
  // lo riscrive la shell, questo lo riscrive matugen, e un JsonAdapter
  // condiviso finirebbe per sovrascrivere l'output a meta' scrittura.
  readonly property string path: Quickshell.env("HOME")
                                 + "/.local/state/quickshell/colors.json"

  // Stessa forma di Net.qml: text() e' reattivo, il reload rivaluta.
  readonly property var data: {
    const t = view.text()
    if (!t) return null
    try {
      const j = JSON.parse(t)
      // Guardia sulla scrittura parziale: watchChanges puo' svegliarci
      // mentre matugen sta ancora scrivendo, e un JSON valido ma monco
      // ci lascerebbe con dei colori undefined per un frame.
      return (j.dark && j.light) ? j : null
    } catch (e) {
      // File a meta': arrivera' un altro fileChanged a scrittura finita.
      return null
    }
  }

  readonly property bool ready: data !== null
  readonly property var dark:  data ? data.dark  : null
  readonly property var light: data ? data.light : null

  FileView {
    id: view
    path: root.path

    // Lettura sincrona: senza, il primo frame nasce coi fallback e vedi
    // un lampo di Catppuccin a ogni riavvio della shell.
    blockLoading: true

    watchChanges: true
    onFileChanged: view.reload()

    // Il file puo' non esistere: e' "matugen mai lanciato", non un errore.
    printErrors: false
  }
}
