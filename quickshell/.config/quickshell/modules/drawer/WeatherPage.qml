// WeatherPage.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../services"


// Pagina del meteo: orologio al centro dell'orbita delle ore, a destra il giorno scelto.
RowLayout {
  id: root
  spacing: Theme.spacingL

  // Giorno mostrato: 0 = oggi. Il cassetto nasce a ogni apertura, quindi riparte da oggi.
  property int day: 0

  readonly property bool today: root.day === 0
  readonly property var info: Weather.daily[root.day] ?? null

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  // Un orologio a parte per l'orbita: il suo modello cambia una volta l'ora, non ogni secondo.
  SystemClock {
    id: hourClock
    precision: SystemClock.Hours
  }

  function step(n) {
    root.day = Math.max(0, Math.min(Weather.daily.length - 1, root.day + n))
    Drawers.poke()
  }

  // ── Orbita delle ore e orologio ─────────────────────────────────────
  // Stesso schema di Today: entrambi riempiono, lo spazio si divide 2 : 1.
  HourOrbit {
    Layout.fillWidth: true
    Layout.preferredWidth: 2
    hours: Weather.hoursFor(root.day, hourClock.hours)
    highlightFirst: root.today

    ColumnLayout {
      spacing: 0

      RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 0

        Text {
          Layout.alignment: Qt.AlignBaseline
          text: Qt.formatDateTime(clock.date, "hh:mm")
          color: Theme.foreground
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontDisplay
          font.weight: Theme.weightBold
        }

        Text {
          Layout.alignment: Qt.AlignBaseline
          text: Qt.formatDateTime(clock.date, ":ss")
          color: Theme.accent
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontXl
          font.weight: Theme.weightBold
        }
      }

      Text {
        Layout.alignment: Qt.AlignHCenter
        text: clock.date.toLocaleDateString(Qt.locale(), "dddd, d MMMM")
        color: Theme.foregroundDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontM
        font.weight: Theme.weightNormal
      }
    }
  }

  // ── Giorno scelto ───────────────────────────────────────────────────
  ColumnLayout {
    Layout.fillWidth: true
    Layout.preferredWidth: 1
    Layout.fillHeight: true
    Layout.topMargin: Theme.spacingL
    Layout.bottomMargin: Theme.spacingL
    Layout.rightMargin: Theme.spacingL
    spacing: Theme.spacingS

    // Intestazione: frecce e nome del giorno, allineate a destra come i numeri sotto.
    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: Theme.spacingL

      Text {
        text: "‹"
        opacity: root.day > 0 ? 1 : 0.3
        color: prevHover.hovered ? Theme.accent : Theme.foregroundDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontXl
        font.weight: Theme.weightBold

        HoverHandler {
          id: prevHover
          cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
          onTapped: root.step(-1)
        }
      }

      Text {
        text: root.today ? "Today"
            : root.info ? Qt.locale().dayName(root.info.date.getDay(), Locale.LongFormat) : ""
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontM
        font.weight: Theme.weightBold
        font.capitalization: Font.AllUppercase
      }

      Text {
        text: "›"
        opacity: root.day < Weather.daily.length - 1 ? 1 : 0.3
        color: nextHover.hovered ? Theme.accent : Theme.foregroundDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontXl
        font.weight: Theme.weightBold

        HoverHandler {
          id: nextHover
          cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
          onTapped: root.step(1)
        }
      }
    }

    // Oggi la temperatura attuale, gli altri giorni la massima.
    Text {
      Layout.alignment: Qt.AlignRight
      text: !Weather.ready ? "--"
          : (root.today ? Weather.temperature : (root.info?.max ?? 0)).toFixed(1) + "°"
      color: Theme.foreground
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontDisplay
      font.weight: Theme.weightBold
    }

    Text {
      Layout.alignment: Qt.AlignRight
      text: root.today ? Weather.description : (root.info?.description ?? "")
      color: Theme.foregroundDim
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontM
      font.weight: Theme.weightNormal
    }

    Text {
      Layout.alignment: Qt.AlignRight
      visible: root.info !== null
      text: "Min " + Math.round(root.info?.min ?? 0) + "°  ·  Max " + Math.round(root.info?.max ?? 0) + "°"
      color: Theme.muted
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontS
    }

    Item { Layout.fillHeight: true }

    // Oggi i valori attuali, gli altri giorni quelli del giorno. Pioggia sempre come probabilita' del giorno.
    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: Theme.spacingL

      // Scala del vento: 60 km/h riempie l'anello, gia' vento forte.
      RingGauge {
        readonly property real wind: root.today ? Weather.windSpeed : (root.info?.wind ?? 0)
        value: wind / 60
        text: Math.round(wind)
        label: "Wind km/h"
      }

      RingGauge {
        readonly property real humidity: root.today ? Weather.humidity : (root.info?.humidity ?? 0)
        value: humidity / 100
        text: Math.round(humidity) + "%"
        label: "Humid"
      }

      RingGauge {
        readonly property real rain: root.info?.rain ?? 0
        value: rain / 100
        text: Math.round(rain) + "%"
        label: "Rain"
      }

      // Scala della percepita: da -10 a 40 gradi.
      RingGauge {
        readonly property real feels: root.today ? Weather.feelsLike : (root.info?.feels ?? 0)
        value: (feels + 10) / 50
        text: Math.round(feels) + "°"
        label: "Feels"
      }
    }
  }
}
