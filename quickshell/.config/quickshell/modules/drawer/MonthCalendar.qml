// MonthCalendar.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../services"


ColumnLayout {
  id: root
  spacing: Theme.spacingS

  // Precisione oraria: basta per spostare "oggi" a mezzanotte.
  SystemClock {
    id: clock
    precision: SystemClock.Hours
  }

  // Il cassetto nasce a ogni apertura: si riparte sempre dal mese corrente.
  property int year:  clock.date.getFullYear()
  property int month: clock.date.getMonth()

  // Giorno scelto: lo decide Today.qml, qui si chiede solo di cambiarlo.
  property var selected: clock.date
  signal picked(var day)

  // Qt conta lunedi'=1..domenica=7, JavaScript domenica=0..sabato=6: % 7 li allinea.
  readonly property int weekStart: Qt.locale().firstDayOfWeek % 7

  // Sei settimane fisse: l'altezza non salta fra mesi da 5 e da 6 righe.
  readonly property var cells: {
    const first = new Date(root.year, root.month, 1)
    const offset = (first.getDay() - root.weekStart + 7) % 7
    const out = []
    for (let i = 0; i < 42; i++)
      out.push(new Date(root.year, root.month, 1 - offset + i))
    return out
  }

  function sameDay(a, b) {
    return a.getDate() === b.getDate()
        && a.getMonth() === b.getMonth()
        && a.getFullYear() === b.getFullYear()
  }

  // Date() gestisce da solo il cambio d'anno: mese 12 diventa gennaio dopo.
  function step(n) {
    const d = new Date(root.year, root.month + n, 1)
    root.year = d.getFullYear()
    root.month = d.getMonth()
    Drawers.poke()
  }

  // Titolo: torna a oggi; il mese segue il giorno scelto.
  function reset() {
    root.picked(clock.date)
    Drawers.poke()
  }

  // Eventi delle 42 celle, piu' il giorno scelto se sei su un altro mese: serve all'agenda.
  function reload() {
    const first = root.cells[0]
    const last = root.cells[41]
    const sel = root.selected
    Events.load(sel < first ? sel : first, sel > last ? sel : last)
  }

  // Si ricarica all'apertura e a ogni cambio di mese.
  onCellsChanged: root.reload()
  Component.onCompleted: root.reload()

  // Giorno scelto in un altro mese (frecce dell'agenda): il calendario lo segue.
  onSelectedChanged: {
    if (root.selected.getMonth() === root.month && root.selected.getFullYear() === root.year) return
    root.year = root.selected.getFullYear()
    root.month = root.selected.getMonth()
  }

  // Intestazione: mese, anno, frecce.
  RowLayout {
    Layout.fillWidth: true
    Layout.leftMargin:  Theme.spacingS
    Layout.rightMargin: Theme.spacingS
    spacing: Theme.spacingM

    // Click sul titolo: torna a oggi.
    Text {
      text: Qt.locale().standaloneMonthName(root.month, Locale.LongFormat) + " " + root.year
      color: titleHover.hovered ? Theme.accent : Theme.foreground
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontL
      font.weight: Theme.weightBold

      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }

      HoverHandler {
        id: titleHover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        onTapped: root.reset()
      }
    }

    Item { Layout.fillWidth: true }

    // Due frecce identiche: un Component costerebbe piu' leggibilita' di quanta ne risparmi.
    Text {
      text: "‹"
      color: prevHover.hovered ? Theme.accent : Theme.foregroundDim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontL
      font.weight: Theme.weightBold

      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }

      HoverHandler {
        id: prevHover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        onTapped: root.step(-1)
      }
    }

    Text {
      text: "›"
      color: nextHover.hovered ? Theme.accent : Theme.foregroundDim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontL
      font.weight: Theme.weightBold

      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }

      HoverHandler {
        id: nextHover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        onTapped: root.step(1)
      }
    }
  }

  GridLayout {
    Layout.fillWidth: true
    columns: 7
    rowSpacing: Theme.spacingXs
    columnSpacing: Theme.spacingXs

    // Colonne identiche qualunque sia il testo: "We" e "Mo" hanno larghezze diverse.
    uniformCellWidths: true

    // Intestazione dei giorni nello stesso grid: colonne allineate per costruzione.
    Repeater {
      model: 7

      delegate: Text {
        required property int index

        text: Qt.locale().dayName((root.weekStart + index) % 7, Locale.ShortFormat).slice(0, 2)
        color: Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontS
        font.weight: Theme.weightBold
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
      }
    }

    Repeater {
      model: root.cells

      delegate: Rectangle {
        id: cell
        required property var modelData

        readonly property bool inMonth: cell.modelData.getMonth() === root.month
        readonly property bool today: root.sameDay(cell.modelData, clock.date)
        readonly property bool chosen: root.sameDay(cell.modelData, root.selected)
        readonly property bool hasEvents: Events.eventsOn(cell.modelData).length > 0

        Layout.fillWidth: true
        // Stessa altezza dei chip della barra: niente numeri magici.
        implicitHeight: Theme.chipHeight

        radius: Theme.radiusS
        antialiasing: true
        // Oggi pieno in accento; il giorno scelto, se diverso, su fondo solido.
        color: cell.today  ? Theme.accent
             : cell.chosen ? Theme.surfaceSolid
                           : "transparent"

        HoverHandler {
          cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
          onTapped: {
            root.picked(cell.modelData)
            Drawers.poke()
          }
        }

        Text {
          anchors.centerIn: parent
          text: cell.modelData.getDate()
          color: cell.today   ? Theme.onAccent
               : cell.inMonth ? Theme.foreground
                              : Theme.muted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontM
          font.weight: cell.today ? Theme.weightBold : Theme.weightNormal
        }

        // Segno degli eventi: barretta arrotondata sotto il numero, non un cerchio.
        Rectangle {
          visible: cell.hasEvents
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: parent.bottom
          anchors.bottomMargin: Theme.spacingXs
          width: Theme.spacingL
          height: Theme.spacingXs
          radius: Theme.radiusS
          color: cell.today   ? Theme.onAccent
               : cell.inMonth ? Theme.accent
                              : Theme.muted
        }
      }
    }

    // Rotella: su = mese precedente, come scorrere indietro nel tempo.
    WheelHandler {
      onWheel: (event) => root.step(event.angleDelta.y > 0 ? -1 : 1)
    }
  }
}
