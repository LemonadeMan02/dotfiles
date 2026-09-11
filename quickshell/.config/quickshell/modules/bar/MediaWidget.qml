// MediaWidget.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

RowLayout {
  id: root
  spacing: 8

  readonly property string iconPlay:         "" // nf-fa-play
  readonly property string iconPause:        "" // nf-fa-pause
  readonly property string iconSkipPrevious: "󰒮" // nf-md-skip_previous
  readonly property string iconSkipNext:     "󰒭" // nf-md-skip_next

  readonly property MprisPlayer player: {
    for (const p of Mpris.players.values) {
      if (p.desktopEntry === "spotify") return p
    }
    return Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
  }

  visible: player !== null

  property real elapsed: player ? player.position : 0

  Timer {
    interval: 1000
    running: root.player !== null && root.player.playbackState === MprisPlaybackState.Playing
    repeat: true
    onTriggered: root.elapsed = root.player.position
  }

  function fmt(sec) {
    if (isNaN(sec) || sec < 0) return "00:00"
    const m = Math.floor(sec / 60)
    const s = Math.floor(sec % 60)
    return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s)
  }

  // Copertina album
  Image {
    id: albumArt
    source: root.player ? root.player.trackArtUrl : ""
    Layout.preferredWidth: 24
    Layout.preferredHeight: 24
    fillMode: Image.PreserveAspectCrop
    visible: root.player && root.player.trackArtUrl !== ""
  }

  // Titolo + timer, impilati verticalmente
  ColumnLayout {
    spacing: 0

    Text {
      text: root.player ? root.player.trackTitle : ""
      color: Theme.foreground
      font.family: Theme.fontFamily
      font.pixelSize: 14
      elide: Text.ElideRight
      Layout.maximumWidth: 160
    }

    Text {
      text: root.player ? root.fmt(root.elapsed) + " / " + root.fmt(root.player.length) : ""
      color: Theme.foreground
      opacity: 0.7
      font.family: Theme.fontFamily
      font.pixelSize: 11
    }
  }

  Text {
    text: root.iconSkipPrevious
    font.family: Theme.nerdFontFamily
    font.pixelSize: 16
    color: Theme.foreground

    MouseArea {
      anchors.fill: parent
      onClicked: root.player.previous()
    }
  }

  Text {
    text: root.player && root.player.playbackState === MprisPlaybackState.Playing ? root.iconPause : root.iconPlay
    font.family: Theme.nerdFontFamily
    font.pixelSize: 16
    color: Theme.foreground

    MouseArea {
      anchors.fill: parent
      onClicked: root.player.togglePlaying()
    }
  }

  Text {
    text: root.iconSkipNext
    font.family: Theme.nerdFontFamily
    font.pixelSize: 16
    color: Theme.foreground

    MouseArea {
      anchors.fill: parent
      onClicked: root.player.next()
    }
  }
}
