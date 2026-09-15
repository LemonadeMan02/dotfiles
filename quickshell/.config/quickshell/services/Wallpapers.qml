// Wallpapers.qml
pragma Singleton

import Quickshell
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
    // Forma ad array: nessun quoting da sbagliare sui path con spazi.
    Quickshell.execDetached(["matugen", "image", path])
  }

  FolderListModel {
    id: folder
    folder: "file://" + root.dir

    nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
    showDirs: false
    sortField: FolderListModel.Name
  }
}
