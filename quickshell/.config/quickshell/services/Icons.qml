// Icons.qml
pragma Singleton

import Quickshell


Singleton {
  id: root

  // Unico posto dove vivono i glifi. Copiali come carattere letterale da
  // nerdfonts.com/cheat-sheet: le trascrizioni esadecimali non sono
  // affidabili. Il commento accanto e' il nome nel cheat-sheet.

  // ── Media ───────────────────────────────────────────────────────────
  readonly property string play:     "" // nf-md-play         (da MediaWidget.qml)
  readonly property string pause:    "" // nf-md-pause        (da MediaWidget.qml)
  readonly property string prev:     "󰒮" // nf-md-skip_previous
  readonly property string next:     "󰒭" // nf-md-skip_next

  // ── Volume ──────────────────────────────────────────────────────────
  readonly property string volMuted:  "" // nf-md-volume_off    (da VolumeWidget.qml)
  readonly property string volLow:    "" // nf-md-volume_low    (da VolumeWidget.qml)
  readonly property string volMedium: "" // nf-md-volume_medium (da VolumeWidget.qml)
  readonly property string volHigh:   "" // nf-md-volume_high   (da VolumeWidget.qml)

  // ── Rete ────────────────────────────────────────────────────────────
  readonly property string wired:   "󰈀" // nf-md-ethernet
  readonly property string wifi:    "" // nf-md-wifi     (da NetworkWidget.qml)
  readonly property string offline: "" // nf-md-wifi_off (da NetworkWidget.qml)

  // ── Sessione ────────────────────────────────────────────────────────
  readonly property string lock:     "" // nf-md-lock        (da QuickSettings.qml)
  readonly property string sleep:    "󰒲" // nf-md-power_sleep (da QuickSettings.qml)
  readonly property string restart:  "" // nf-md-restart     (da Dashboard.qml)
  readonly property string shutdown: "" // nf-md-power       (da Dashboard.qml)

  // ── Interfaccia ─────────────────────────────────────────────────────
  readonly property string light:   "󰌵" // nf-md-white_balance_sunny (da QuickSettings.qml)
  readonly property string dark:    "" // nf-md-weather_night       (da QuickSettings.qml)
  readonly property string opacity: "󱡕" // nf-md-opacity             (da QuickSettings.qml)
  readonly property string back:    "" // nf-md-arrow_left          (da QuickSettings.qml)
  readonly property string search:  "" // nf-md-magnify             (da Launcher.qml)
  readonly property string command: "" // nf-md-chevron_right       (da Launcher.qml)
  readonly property string app: "" // nf-md-application

  // ── Meteo ───────────────────────────────────────────────────────────
  readonly property string wClear:       "󰖨" // nf-md-weather_sunny
  readonly property string wClearNight:  "󰖔" // nf-md-weather_night
  readonly property string wPartly:      "" // nf-md-weather_partly_cloudy       (da Weather.qml)
  readonly property string wPartlyNight: "" // nf-md-weather_night_partly_cloudy (da Weather.qml)
  readonly property string wCloudy:      "" // nf-md-weather_cloudy              (da Weather.qml)
  readonly property string wOvercast:    "" // nf-md-weather_cloudy              (da Weather.qml)
  readonly property string wFog:         "󰖑" // nf-md-weather_fog
  readonly property string wDrizzle:     "" // nf-md-weather_partly_rainy        (da Weather.qml)
  readonly property string wRain:        "" // nf-md-weather_rainy               (da Weather.qml)
  readonly property string wPouring:     "󰖖" // nf-md-weather_pouring
  readonly property string wSnow:        "" // nf-md-weather_snowy               (da Weather.qml)
  readonly property string wSleet:       "" // nf-md-weather_snowy_rainy         (da Weather.qml)
  readonly property string wThunder:     "" // nf-md-weather_lightning           (da Weather.qml)
  readonly property string wHail:        "" // nf-md-weather_hail                (da Weather.qml)
}
