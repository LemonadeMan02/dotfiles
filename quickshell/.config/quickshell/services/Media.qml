// Media.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick


Singleton {
  id: root

  // Unico posto dove si sceglie il player: barra e tasti comandano lo stesso.
  // Spotify ha la precedenza, poi il primo che c'e'.
  readonly property MprisPlayer player: {
    for (const p of Mpris.players.values)
      if (p.desktopEntry === "spotify") return p
    return Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
  }

  readonly property bool playing: root.player !== null
                                  && root.player.playbackState === MprisPlaybackState.Playing

  function playPause() { if (root.player) root.player.togglePlaying() }
  function next()      { if (root.player) root.player.next() }
  function previous()  { if (root.player) root.player.previous() }

  // position non notifica da sola mentre il brano avanza: il segnale fa rivalutare i binding.
  Timer {
    interval: 1000
    running: root.playing
    repeat: true
    onTriggered: root.player.positionChanged()
  }

  // Ingresso per script e terminale: qs ipc call media <funzione>.
  IpcHandler {
    target: "media"

    function playPause(): void { root.playPause() }
    function next():      void { root.next() }
    function previous():  void { root.previous() }
  }

  // Tasti multimediali: stessa via dei cassetti, nessun processo lanciato a ogni pressione.
  GlobalShortcut {
    appid: "quickshell"
    name: "mediaPlayPause"
    description: "Play/pausa del player scelto"

    onPressed: root.playPause()
  }

  GlobalShortcut {
    appid: "quickshell"
    name: "mediaNext"
    description: "Brano successivo"

    onPressed: root.next()
  }

  GlobalShortcut {
    appid: "quickshell"
    name: "mediaPrevious"
    description: "Brano precedente"

    onPressed: root.previous()
  }
}
