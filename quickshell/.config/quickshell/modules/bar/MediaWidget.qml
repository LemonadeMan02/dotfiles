// MediaWidget.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../../services"

RowLayout {
  id: root
  spacing: Theme.spacingM

  readonly property string iconPlay:         "" // nf-md-play
  readonly property string iconPause:        "" // nf-md-pause
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
      font.pixelSize: Theme.fontM
      font.weight: Theme.weightBold
      elide: Text.ElideRight
      Layout.maximumWidth: 160
    }

    Text {
      text: root.player ? root.fmt(root.elapsed) + " / " + root.fmt(root.player.length) : ""
      color: Theme.foregroundDim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontXs
      font.weight: Theme.weightNormal
    }
  }

  // Controlli raggruppati: il margine sinistro stacca il blocco dal testo,
  // le tre icone restano strette tra loro.
  RowLayout {
    spacing: Theme.spacingS + 10
    Layout.leftMargin: Theme.spacingM

    // I tre pulsanti condividono struttura identica: un Text con hover e
    // tap. Il Component + Repeater eviterebbe la ripetizione, ma a tre
    // elementi costa piu' leggibilita' di quanta ne faccia risparmiare.

    Text {
      id: prevBtn
      text: root.iconSkipPrevious
      font.family: Theme.nerdFontFamily
      font.pixelSize: Theme.iconM
      // L'icona si accende sotto il mouse: e' l'unico segnale che il
      // controllo sia cliccabile.
      color: prevHover.hovered ? Theme.accent : Theme.foreground

      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }

      HoverHandler {
        id: prevHover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        // La guardia serve: la pill e' nascosta quando player e' null, ma
        // non e' una garanzia, e' solo una coincidenza di layout.
        onTapped: if (root.player) root.player.previous()
      }
    }

    Text {
      id: playBtn
      text: root.player && root.player.playbackState === MprisPlaybackState.Playing
            ? root.iconPause : root.iconPlay
      font.family: Theme.nerdFontFamily
      font.pixelSize: Theme.iconM
      color: playHover.hovered ? Theme.accent : Theme.foreground

      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }

      HoverHandler {
        id: playHover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        onTapped: if (root.player) root.player.togglePlaying()
      }
    }

    Text {
      id: nextBtn
      text: root.iconSkipNext
      font.family: Theme.nerdFontFamily
      font.pixelSize: Theme.iconM
      color: nextHover.hovered ? Theme.accent : Theme.foreground

      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }

      HoverHandler {
        id: nextHover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        onTapped: if (root.player) root.player.next()
      }
    }
  }
}
