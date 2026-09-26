// Wallpapers.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import QtQuick


Singleton {
  id: root

  // Il ripiego sta qui e non nel JsonObject: quello vuole un default
  // costante, e HOME si sa solo a runtime.
  readonly property string dir: {
    const d = Config.appearance?.wallpaperDir ?? ""
    return d !== "" ? d : Quickshell.env("HOME") + "/Wallpapers"
  }

  readonly property string current: Config.appearance?.wallpaper ?? ""

  // Il modello esce crudo: il carosello lo da' direttamente a una ListView
  // invece di copiarlo in un array che andrebbe tenuto in sincronia.
  property alias model: folder
  readonly property int count: folder.count

  // Modalita' per matugen: kitty e Hyprland usano i colori .default, che la seguono.
  readonly property string mode: (Config.appearance?.darkMode ?? true) ? "dark" : "light"

  // Richiesta arrivata mentre matugen gira: rilanciata a fine giro con lo stato di allora.
  property bool pending: false

  // Vero dopo l'avvio: un cambio di mode mentre la config si carica non deve rilanciare matugen.
  property bool started: false

  Component.onCompleted: root.started = true

  // Cambio chiaro/scuro: stessa immagine, palette dell'altra modalita'.
  onModeChanged: if (root.started) root.regenerate()

  // FolderListModel espone i ruoli solo via get(): serve al picker per
  // sapere cosa sta evidenziando senza frugare nel delegate.
  function pathAt(i) {
    if (i < 0 || i >= folder.count) return ""
    return folder.get(i, "filePath")
  }

  // Un solo punto d'ingresso: scrive lo stato e lancia matugen, che da li'
  // in poi fa tutto lui (sfondo via awww, colors.json, e Colors se ne accorge).
  function apply(path) {
    if (!path) return
    Config.setWallpaper(path)
    root.regenerate()
  }

  // Un giro alla volta: due matugen insieme scriverebbero gli stessi file a meta'.
  function regenerate() {
    if (root.current === "") return
    if (proc.running) {
      root.pending = true
      return
    }
    // Forma ad array: nessun quoting da sbagliare sui path con spazi.
    proc.command = ["matugen", "image", root.current, "-m", root.mode]
    proc.running = true
  }

  // Il comando si assegna al lancio: legato con un binding cambierebbe durante il giro.
  Process {
    id: proc

    onExited: (exitCode, exitStatus) => {
      if (exitCode !== 0) console.warn("Wallpapers: matugen uscito con codice", exitCode)
      if (root.pending) {
        root.pending = false
        root.regenerate()
      }
    }
  }

  FolderListModel {
    id: folder
    folder: "file://" + root.dir

    nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
    showDirs: false
    sortField: FolderListModel.Name
  }
}
