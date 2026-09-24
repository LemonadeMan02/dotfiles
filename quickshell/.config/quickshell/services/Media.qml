// Media.qml
pragma Singleton

import Quickshell
import Quickshell.Io
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

  // Ingresso per i tasti multimediali: qs ipc call media <funzione>.
  IpcHandler {
    target: "media"

    function playPause(): void { root.playPause() }
    function next():      void { root.next() }
    function previous():  void { root.previous() }
  }
}
