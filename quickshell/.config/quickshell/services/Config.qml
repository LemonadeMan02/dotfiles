// Config.qml
pragma Singleton

import Quickshell
import Quickshell.Io


Singleton {
  id: root

  // Il resto della shell legge Config.appearance.*, non tocca mai il FileView.
  property alias appearance: adapter.appearance
  property alias drawer:     adapter.drawer


  function toggleDarkMode() {
    adapter.appearance.darkMode = !adapter.appearance.darkMode
  }

  function setTransparency(v) {
    adapter.appearance.transparency = Math.max(0, Math.min(1, v))
  }

  FileView {
    id: view
    path: Quickshell.env("HOME") + "/.local/state/quickshell/config.json"

    // Lettura sincrona: senza, il primo frame nasce con i default e vedi
    // un lampo di tema sbagliato all'avvio.
    blockLoading: true

    // Rileggi se il file cambia da fuori (editor, script, matugen domani).
    watchChanges: true
    onFileChanged: view.reload()

    // Ogni assegnazione su adapter.* finisce su disco. E' questo che rende
    // il JsonAdapter bidirezionale: non serve una funzione save().
    onAdapterUpdated: view.writeAdapter()

    // Primo avvio: il file non esiste ancora, lo scriviamo con i default.
    onLoadFailed: (error) => {
      if (error === FileViewError.FileNotFound) view.writeAdapter()
    }

    JsonAdapter {
      id: adapter

      // Ogni sezione di primo livello corrisponde a un'area della shell.
      // Aggiungeremo "drawer", "paths", "bar" quando serviranno davvero.
      property JsonObject appearance: JsonObject {
        property bool darkMode: false

        // 0 = pill opache, 1 = pill invisibili. Salviamo il valore che
        // l'utente vede nello slider, non l'alpha: una sola conversione,
        // in Theme, invece di doppie negazioni sparse.
        property real transparency: 0.30
      }
      property JsonObject drawer: JsonObject {
        property int autoCloseTimeout: 20000
      }
    }
  }
}
