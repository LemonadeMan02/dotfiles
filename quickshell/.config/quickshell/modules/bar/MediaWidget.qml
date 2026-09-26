// MediaWidget.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../../services"

RowLayout {
  id: root
  spacing: Theme.spacingM

  // La scelta del player vive in Media: qui solo un nome corto. Bar.qml lo legge.
  readonly property MprisPlayer player: Media.player

  visible: player !== null

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

    // Binding diretto su position: il Timer in Media lo tiene vivo.
    Text {
      text: root.player ? root.fmt(root.player.position) + " / " + root.fmt(root.player.length) : ""
      color: Theme.foregroundDim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontXs
      font.weight: Theme.weightNormal
    }
  }

  // Controlli raggruppati: il margine sinistro stacca il blocco dal testo,
  // la spaziatura fra le icone viene dalla scala del Theme come tutte le altre.
  RowLayout {
    spacing: Theme.spacingL
    Layout.leftMargin: Theme.spacingM

    // I tre pulsanti condividono struttura identica: un Text con hover e
    // tap. Il Component + Repeater eviterebbe la ripetizione, ma a tre
    // elementi costa piu' leggibilita' di quanta ne faccia risparmiare.

    Text {
      id: prevBtn
      text: Icons.prev
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

      // La guardia su player sta in Media: vale anche per i tasti.
      TapHandler {
        onTapped: Media.previous()
      }
    }

    Text {
      id: playBtn
      text: Media.playing ? Icons.pause : Icons.play
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
        onTapped: Media.playPause()
      }
    }

    Text {
      id: nextBtn
      text: Icons.next
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
        onTapped: Media.next()
      }
    }
  }
}
