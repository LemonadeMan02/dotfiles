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

  function reset() {
    root.year = clock.date.getFullYear()
    root.month = clock.date.getMonth()
    Drawers.poke()
  }

  // Intestazione: mese, anno, frecce.
  RowLayout {
    Layout.fillWidth: true
    Layout.leftMargin:  Theme.spacingS
    Layout.rightMargin: Theme.spacingS
    spacing: Theme.spacingM

    // Click sul titolo: torna al mese corrente.
    Text {
      text: Qt.locale().standaloneMonthName(root.month, Locale.LongFormat) + " " + root.year
      color: titleHover.hovered ? Theme.accent : Theme.foreground
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontM
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
        font.pixelSize: Theme.fontXs
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

        Layout.fillWidth: true
        implicitHeight: 30

        radius: Theme.radiusS
        antialiasing: true
        color: cell.today ? Theme.accent : "transparent"

        Text {
          anchors.centerIn: parent
          text: cell.modelData.getDate()
          color: cell.today   ? Theme.onAccent
               : cell.inMonth ? Theme.foreground
                              : Theme.muted
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontS
          font.weight: cell.today ? Theme.weightBold : Theme.weightNormal
        }
      }
    }

    // Rotella: su = mese precedente, come scorrere indietro nel tempo.
    WheelHandler {
      onWheel: (event) => root.step(event.angleDelta.y > 0 ? -1 : 1)
    }
  }
}
