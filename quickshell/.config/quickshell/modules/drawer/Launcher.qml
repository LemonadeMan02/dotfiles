// Launcher.qml
import QtQuick
import QtQuick.Layouts
import "../common"
import "../../services"


ColumnLayout {
  id: root
  spacing: Theme.spacingM

  // Chiamata da chi ospita il launcher, quando la finestra ha davvero il
  // focus Wayland: prima di quel momento un forceActiveFocus() si perde.
  function focusSearch() { search.forceFocus() }

  // Numero massimo di righe mostrate. Oltre, il pannello diventa piu'
  // alto dello schermo e l'animazione perde senso.
  readonly property int maxRows: 8

  // Il > iniziale commuta la modalita' e non fa parte del testo cercato.
  readonly property bool commandMode: search.text.startsWith(">")
  readonly property string query: commandMode ? search.text.slice(1) : search.text

  // Indice della riga evidenziata. -1 non esiste: se la lista e' vuota
  // non c'e' nulla da lanciare e il controllo lo fa activate().
  property int selected: 0

  readonly property var results: root.commandMode
      ? commands.filtered(root.query)
      : Apps.search(root.query)

  // Ogni cambio di query azzera la selezione: tenerla ferma su un indice
  // che ora punta a un'altra voce e' il modo piu' rapido per lanciare
  // l'applicazione sbagliata.
  onResultsChanged: root.selected = 0

  function move(delta) {
    const n = root.results.length
    if (n === 0) return
    // Modulo con correzione: in JS -1 % 8 fa -1, non 7.
    root.selected = ((root.selected + delta) % n + n) % n
  }

  function activate() {
    if (root.selected < 0 || root.selected >= root.results.length) return
    const item = root.results[root.selected]

    if (root.commandMode) {
      item.action()
    } else {
      // Chiudi prima di lanciare: il focus-grab sopravvivrebbe alla
      // finestra nuova e se la mangerebbe.
      Drawers.close()
      Apps.launch(item)
    }
  }

  // ── Comandi. La forma imita DesktopEntry: name, comment, icon, cosi'
  //    il delegate della lista non deve sapere in che modalita' siamo. ──
  QtObject {
    id: commands

    readonly property var all: [
      {
        name: "Transparency",
        comment: "Change shell transparency",
        icon: Icons.opacity,
        action: () => root.showTransparency()
      },
      {
        name: "Light",
        comment: "Change the scheme to light mode",
        icon: Icons.light,
        action: () => Config.setDarkMode(false)
      },
      {
        name: "Dark",
        comment: "Change the scheme to dark mode",
        icon: Icons.dark,
        action: () => Config.setDarkMode(true)
      },
      {
        name: "Lock",
        comment: "Lock the current session",
        icon: Icons.lock,
        action: () => { Drawers.close(); Session.lock() }
      },
      {
        name: "Sleep",
        comment: "Suspend the system",
        icon: Icons.sleep,
        action: () => { Drawers.close(); Session.sleep() }
      }
    ]

    function filtered(q) {
      const out = []
      for (const c of commands.all) {
        const s = Apps.score(c.name, q)
        if (s >= 0) out.push({ item: c, score: s })
      }
      out.sort((a, b) => b.score - a.score)
      return out.map(x => x.item)
    }
  }

  // ── Pagina 0: lista. Pagina 1: trasparenza. ─────────────────────────
  property int page: 0

  function showTransparency() { root.page = 1 }

  StackLayout {
    Layout.fillWidth: true
    currentIndex: root.page

    // Lista dei risultati.
    ColumnLayout {
      spacing: Theme.spacingXs

      Repeater {
        model: root.results.slice(0, root.maxRows)

        delegate: ListEntry {
          required property var modelData
          required property int index

          Layout.fillWidth: true

          // In modalita' comandi un glifo, in modalita' app l'icona vera.
          icon:       root.commandMode ? modelData.icon : ""
          iconSource: root.commandMode ? "" : Apps.iconFor(modelData)

          title: modelData.name
          subtitle: root.commandMode ? modelData.comment
                                     : (modelData.comment ?? "")

          // Evidenziazione da tastiera: la riga la espone come proprieta'
          // cosi' il mouse e le frecce non si contendono lo stato.
          highlighted: index === root.selected

          onActivated: {
            root.selected = index
            root.activate()
          }
        }
      }

      Text {
        visible: root.results.length === 0
        Layout.fillWidth: true
        Layout.margins: Theme.spacingL
        text: "Nessun risultato"
        color: Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontM
      }
    }

    // Trasparenza: pagina piena, la ricerca resta visibile ma inerte.
    ColumnLayout {
      spacing: Theme.spacingM

      ListEntry {
        Layout.fillWidth: true
        icon: Icons.back
        title: "Transparency"
        subtitle: Math.round((Config.appearance?.transparency ?? 0.30) * 100) + "%"
        onActivated: root.page = 0
      }

      Slider {
        Layout.fillWidth: true
        Layout.leftMargin:   Theme.spacingL
        Layout.rightMargin:  Theme.spacingL
        Layout.bottomMargin: Theme.spacingM

        value: Config.appearance?.transparency ?? 0.30
        onMoved: (v) => Config.setTransparency(v)
      }
    }
  }

  SearchField {
    id: search
    Layout.fillWidth: true
    Layout.topMargin: Theme.spacingS

    icon: root.commandMode ? Icons.command : Icons.search
    placeholder: root.commandMode ? "Comando..." : "Cerca applicazioni..."

    onAccepted:  root.activate()
    onMoveUp:    root.move(-1)
    onMoveDown:  root.move(1)

    // Escape: prima torna alla lista, poi chiude. Due livelli, come
    // l'abitudine vuole.
    onCancelled: {
      if (root.page !== 0) root.page = 0
      else Drawers.close()
    }
  }
}
