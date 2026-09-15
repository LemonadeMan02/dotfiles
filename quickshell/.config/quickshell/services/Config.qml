// Config.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick


Singleton {
  id: root

  // Il resto della shell legge Config.appearance.*, non tocca mai il FileView.
  property alias appearance: adapter.appearance
  property alias drawer:     adapter.drawer

  // Scrittura differita. Il drag dello slider chiama il setter a ogni frame:
  // il timer riparte, il disco viene toccato una volta sola a fine gesto.
  Timer {
    id: writeDebounce
    interval: 300
    onTriggered: view.writeAdapter()
  }

  function save() { writeDebounce.restart() }

  function setDarkMode(v) {
    adapter.appearance.darkMode = v
    root.save()
  }

  function toggleDarkMode() {
    root.setDarkMode(!adapter.appearance.darkMode)
  }

  function setTransparency(v) {
    adapter.appearance.transparency = Math.max(0, Math.min(1, v))
    root.save()
  }

  function setDynamicColors(v) {
    adapter.appearance.dynamicColors = v
    root.save()
  }

  function toggleDynamicColors() {
    root.setDynamicColors(!adapter.appearance.dynamicColors)
  }

  function setWallpaper(path) {
    adapter.appearance.wallpaper = path
    root.save()
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

    // Niente onAdapterUpdated: la scrittura parte dai setter qui sopra.
    // Cosi' il nostro write non si auto-inseque via fileChanged.

    // Primo avvio: il file non esiste ancora, lo scriviamo con i default.
    onLoadFailed: (error) => {
      if (error === FileViewError.FileNotFound) view.writeAdapter()
    }

    JsonAdapter {
      id: adapter

      // Ogni sezione di primo livello corrisponde a un'area della shell.
      property JsonObject appearance: JsonObject {
        // Mocha e' la base di design: il default deve dirlo.
        property bool darkMode: true

        // 0 = pill opache, 1 = pill invisibili. Salviamo il valore che
        // l'utente vede nello slider, non l'alpha.
        property real transparency: 0.30

        // Se false, Catppuccin anche quando colors.json esiste. Serve a
        // tornare indietro senza cancellare file.
        property bool dynamicColors: true

        // "" = ripiego su ~/Wallpapers. Risolto in Wallpapers.qml, non qui:
        // un JsonObject vuole un default costante.
        property string wallpaperDir: ""

        // Path dell'immagine applicata. Vive qui e non solo nella cache di
        // awww, perche' il picker deve sapere quale evidenziare.
        property string wallpaper: ""
      }
      property JsonObject drawer: JsonObject {
        property int autoCloseTimeout: 20000
      }
    }
  }
}
