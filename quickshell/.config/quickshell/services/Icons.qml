// Icons.qml
pragma Singleton

import Quickshell


Singleton {
  id: root

  // Unico posto dove vivono i glifi. Copiali come carattere letterale da
  // nerdfonts.com/cheat-sheet: le trascrizioni esadecimali non sono
  // affidabili. Il commento accanto e' il nome nel cheat-sheet.

  // ── Media ───────────────────────────────────────────────────────────
  readonly property string play:     "" // nf-md-play
  readonly property string pause:    "" // nf-md-pause
  readonly property string prev:     "󰒮" // nf-md-skip_previous
  readonly property string next:     "󰒭" // nf-md-skip_next

  // ── Volume ──────────────────────────────────────────────────────────
  readonly property string volMuted:  "" // nf-md-volume_off
  readonly property string volLow:    "" // nf-md-volume_low
  readonly property string volMedium: "" // nf-md-volume_medium
  readonly property string volHigh:   "" // nf-md-volume_high

  // ── Rete ────────────────────────────────────────────────────────────
  readonly property string wired:   "󰈀" // nf-md-ethernet
  readonly property string wifi:    "" // nf-md-wifi
  readonly property string offline: "" // nf-md-wifi_off

  // ── Sessione ────────────────────────────────────────────────────────
  readonly property string lock:     "" // nf-md-lock
  readonly property string sleep:    "󰒲" // nf-md-power_sleep
  readonly property string restart:  "" // nf-md-restart
  readonly property string shutdown: "" // nf-md-power

  // ── Interfaccia ─────────────────────────────────────────────────────
  readonly property string light:   "󰌵" // nf-md-white_balance_sunny
  readonly property string dark:    "" // nf-md-weather_night
  readonly property string opacity: "󱡕" // nf-md-opacity
  readonly property string back:    "" // nf-md-arrow_left
  readonly property string search:  "" // nf-md-magnify
  readonly property string command: "" // nf-md-chevron_right
  readonly property string app: "󱃶" // nf-md-application

  // ── Meteo ───────────────────────────────────────────────────────────
  readonly property string wClear:       "󰖨" // nf-md-weather_sunny
  readonly property string wClearNight:  "󰖔" // nf-md-weather_night
  readonly property string wPartly:      "" // nf-md-weather_partly_cloudy
  readonly property string wPartlyNight: "" // nf-md-weather_night_partly_cloudy
  readonly property string wCloudy:      "" // nf-md-weather_cloudy
  readonly property string wOvercast:    "" // nf-md-weather_cloudy
  readonly property string wFog:         "󰖑" // nf-md-weather_fog
  readonly property string wDrizzle:     "" // nf-md-weather_partly_rainy
  readonly property string wRain:        "" // nf-md-weather_rainy
  readonly property string wPouring:     "󰖖" // nf-md-weather_pouring
  readonly property string wSnow:        "" // nf-md-weather_snowy
  readonly property string wSleet:       "" // nf-md-weather_snowy_rainy
  readonly property string wThunder:     "" // nf-md-weather_lightning
  readonly property string wHail:        "" // nf-md-weather_hail

    // ── Wallpapers ───────────────────────────────────────────────────────────
  readonly property string wallpaper: "󰸉" // nf-md-image
}
