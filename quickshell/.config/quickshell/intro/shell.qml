// intro/shell.qml: animazione d'ingresso della sessione, la lancia session-intro (scripts/)
// all'avvio di Hyprland. Copre gli schermi di nero, mostra lo sfondo sfocato come il greeter
// e, quando sotto di lei sfondo (awww) e barra sono a schermo, lo mette a fuoco e sparisce.
// Istanza a parte, senza i servizi della shell: deve comparire prima di tutto il resto
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects


ShellRoot {
  id: root

  // Desktop pronto sotto la copertura: parte la messa a fuoco
  property bool revealing: false

  // Durate: entrata dello sfondo sfocato, messa a fuoco, dissolvenza finale dentro la messa a fuoco
  readonly property int durIn:     350
  readonly property int durReveal: 900
  readonly property int durOut:    350

  // Lo sfondo scelto nella shell, lo stesso che awww ripristina sotto
  readonly property string wallpaper: {
    const t = configView.text()
    if (!t) return ""
    try {
      return JSON.parse(t).appearance?.wallpaper ?? ""
    } catch (e) {
      return ""
    }
  }

  FileView {
    id: configView
    path: Quickshell.env("HOME") + "/.local/state/quickshell/config.json"
    blockLoading: true
    // Senza config.json (shell mai avviata) niente sfondo: si svela dal nero
    printErrors: false
  }

  // Pronto quando ogni schermo ha il suo sfondo (livello 0) e la barra e' comparsa
  function check(text) {
    let layers
    try {
      layers = JSON.parse(text)
    } catch (e) {
      return
    }

    const monitors = Object.values(layers)
    const wallpapers = monitors.length > 0
                       && monitors.every(m => (m.levels?.["0"] ?? []).length > 0)
    const bar = monitors.some(m => Object.values(m.levels ?? {})
                                     .some(l => l.some(s => s.namespace === "quickshell:bar")))

    if (wallpapers && bar && !settle.running) {
      console.log("intro: sfondo e barra a schermo")
      poll.stop()
      settle.start()
    }
  }

  Process {
    id: probe
    command: ["hyprctl", "layers", "-j"]
    stdout: StdioCollector {
      onStreamFinished: root.check(text)
    }
  }

  Timer {
    id: poll
    interval: 100
    repeat: true
    running: true
    onTriggered: if (!probe.running) probe.running = true
  }

  // Le superfici appena comparse entrano con la dissolvenza di Hyprland (layersIn, 400ms):
  // si aspetta che finisca, sotto la copertura
  Timer {
    id: settle
    interval: 500
    onTriggered: root.revealing = true
  }

  // Tetto: se sfondo o barra non arrivano, si svela comunque
  Timer {
    interval: 6000
    running: true
    onTriggered: root.revealing = true
  }

  // A messa a fuoco finita l'istanza esce: session-intro toglie il segnale per awww e quickshell
  Timer {
    interval: root.durReveal + 100
    running: root.revealing
    onTriggered: Qt.quit()
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: win

      required property var modelData

      screen: modelData
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      // Trasparente: alla fine si dissolve il contenuto e sotto c'e' il desktop
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      // Con questo nome la aspettano awww e quickshell (session-intro wait), e in
      // layerrules.lua niente dissolvenza di Hyprland: deve coprire dal primo fotogramma
      WlrLayershell.namespace: "session-intro"
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      // Nessuna regione d'input: click e tasti passano gia' al desktop sotto
      mask: Region {}

      Item {
        id: content
        anchors.fill: parent

        Rectangle {
          anchors.fill: parent
          color: "black"
        }

        Image {
          id: wall
          anchors.fill: parent
          source: root.wallpaper !== "" ? "file://" + root.wallpaper : ""
          // Come awww: riempie lo schermo e taglia i bordi
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
          visible: false
        }

        // Sfondo sfocato e scurito come nel greeter: entra dal nero appena decodificato
        Item {
          anchors.fill: parent
          opacity: wall.status === Image.Ready ? 1 : 0

          Behavior on opacity { NumberAnimation { duration: root.durIn } }

          MultiEffect {
            id: fx
            anchors.fill: parent
            source: wall
            blurEnabled: true
            blur: 1.0
            blurMax: 48
            autoPaddingEnabled: false
            // Leggero zoom che si ritrae durante la messa a fuoco
            scale: 1.05
          }

          Rectangle {
            id: scrim
            anchors.fill: parent
            color: "black"
            opacity: 0.4
          }
        }
      }

      // Messa a fuoco: sfocatura, velo e zoom vanno a zero insieme, poi tutto si dissolve
      // sul desktop vero, che sotto mostra lo stesso sfondo
      ParallelAnimation {
        running: root.revealing

        NumberAnimation { target: fx;    property: "blur";    to: 0; duration: root.durReveal; easing.type: Easing.OutCubic }
        NumberAnimation { target: fx;    property: "scale";   to: 1; duration: root.durReveal; easing.type: Easing.OutCubic }
        NumberAnimation { target: scrim; property: "opacity"; to: 0; duration: root.durReveal; easing.type: Easing.OutCubic }

        SequentialAnimation {
          PauseAnimation  { duration: root.durReveal - root.durOut }
          NumberAnimation { target: content; property: "opacity"; to: 0; duration: root.durOut; easing.type: Easing.InOutQuad }
        }
      }
    }
  }
}
