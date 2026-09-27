// Weather.qml
pragma Singleton

import Quickshell
import QtQuick


Singleton {
  id: root

  readonly property real latitude: 41.9
  readonly property real longitude: 12.5

  // Giorni di previsione chiesti a Open-Meteo; le ore arrivano per tutti questi giorni.
  readonly property int forecastDays: 7

  // False finche' non arriva la prima risposta valida: 0 gradi non e' "nessun dato".
  property bool ready: false

  property real temperature: 0
  property int weatherCode: 0
  property bool isDay: true
  property real feelsLike: 0
  property int humidity: 0
  property real windSpeed: 0

  // Tutte le ore da mezzanotte di oggi: [{ time: "22:00", temp, icon, rain }]
  property var hourly: []

  // Prossimi giorni: [{ date, max, min, feels, wind, humidity, rain, icon, description }]
  property var daily: []

  function refresh() {
    const xhr = new XMLHttpRequest()
    const url = "https://api.open-meteo.com/v1/forecast?latitude=" + root.latitude
              + "&longitude=" + root.longitude
              + "&current=temperature_2m,weather_code,is_day,apparent_temperature,relative_humidity_2m,wind_speed_10m"
              + "&hourly=temperature_2m,weather_code,is_day,precipitation_probability"
              + "&daily=weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,"
              + "precipitation_probability_max,wind_speed_10m_max,relative_humidity_2m_mean"
              + "&forecast_days=" + root.forecastDays
              // Orari e date nel fuso locale, ore a partire dalla mezzanotte di oggi.
              + "&timezone=auto"

    xhr.onreadystatechange = function() {
      if (xhr.readyState !== XMLHttpRequest.DONE) return

      // status 0 = rete assente o DNS fallito: stesso trattamento di un errore HTTP.
      if (xhr.status !== 200) {
        console.warn("Weather: richiesta fallita, status", xhr.status)
        retry.restart()
        return
      }

      try {
        root.apply(JSON.parse(xhr.responseText))
        root.ready = true
        retry.stop()
      } catch (e) {
        // Risposta 200 ma forma inattesa: meglio riprovare che mostrare undefined.
        console.warn("Weather: risposta non valida", e)
        retry.restart()
      }
    }

    xhr.open("GET", url)
    xhr.send()
  }

  // Separata dalla rete: si puo' provare con una risposta scritta a mano.
  function apply(data) {
    const c = data.current
    root.temperature = c.temperature_2m
    root.weatherCode = c.weather_code
    root.isDay = c.is_day === 1
    root.feelsLike = c.apparent_temperature
    root.humidity = c.relative_humidity_2m
    root.windSpeed = c.wind_speed_10m

    // Array paralleli di Open-Meteo → un oggetto per ora; "2026-09-27T22:00" → "22:00".
    const h = data.hourly
    root.hourly = h.time.map((t, i) => ({
      time: t.slice(11, 16),
      temp: h.temperature_2m[i],
      icon: root.iconFor(h.weather_code[i], h.is_day[i] === 1),
      rain: h.precipitation_probability[i] ?? 0
    }))

    // Date costruite a mano: new Date("2026-09-27") sarebbe mezzanotte UTC, non locale.
    const d = data.daily
    root.daily = d.time.map((t, i) => ({
      date: new Date(+t.slice(0, 4), +t.slice(5, 7) - 1, +t.slice(8, 10)),
      max: d.temperature_2m_max[i],
      min: d.temperature_2m_min[i],
      feels: d.apparent_temperature_max[i],
      wind: d.wind_speed_10m_max[i],
      humidity: d.relative_humidity_2m_mean[i],
      rain: d.precipitation_probability_max[i] ?? 0,
      icon: root.iconFor(d.weather_code[i], true),
      description: root.describe(d.weather_code[i])
    }))
  }

  // Ore per l'orbita: oggi le prossime otto dall'ora corrente, gli altri giorni una ogni tre.
  function hoursFor(day, nowHour) {
    if (day === 0) return root.hourly.slice(nowHour, nowHour + 8)
    return root.hourly.slice(day * 24, day * 24 + 24).filter((h, i) => i % 3 === 0)
  }

  // Codici WMO 4677, come esposti da Open-Meteo nel campo weather_code.
  // day: le previsioni orarie hanno il loro giorno/notte, quelle giornaliere sono sempre di giorno.
  function iconFor(code, day) {
    // Sereno e quasi sereno: unici due casi in cui il sole si vede davvero,
    // quindi gli unici che hanno senso alternare giorno/notte.
    if (code === 0)  return day ? Icons.wClear  : Icons.wClearNight
    if (code === 1)  return day ? Icons.wClear  : Icons.wClearNight
    if (code === 2)  return day ? Icons.wPartly : Icons.wPartlyNight

    if (code === 3)  return Icons.wOvercast                  // coperto

    if (code === 45 || code === 48) return Icons.wFog        // nebbia, anche con brina

    if (code >= 51 && code <= 57) return Icons.wDrizzle      // pioviggine, gelata inclusa
    if (code >= 61 && code <= 67) return Icons.wRain         // pioggia, gelata inclusa
    if (code >= 71 && code <= 77) return Icons.wSnow         // neve e granelli
    if (code >= 80 && code <= 82) return Icons.wPouring      // rovesci intermittenti
    if (code >= 85 && code <= 86) return Icons.wSleet        // rovesci di neve

    if (code === 95) return Icons.wThunder                   // temporale
    if (code >= 96 && code <= 99) return Icons.wHail         // temporale con grandine

    return Icons.wClear
  }

  // Stessi gruppi di iconFor, a parole: testi dell'interfaccia in inglese.
  function describe(code) {
    if (code === 0) return "Clear sky"
    if (code === 1) return "Mainly clear"
    if (code === 2) return "Partly cloudy"
    if (code === 3) return "Overcast"
    if (code === 45 || code === 48) return "Fog"
    if (code >= 51 && code <= 55) return "Drizzle"
    if (code >= 56 && code <= 57) return "Freezing drizzle"
    if (code >= 61 && code <= 65) return "Rain"
    if (code >= 66 && code <= 67) return "Freezing rain"
    if (code >= 71 && code <= 77) return "Snow"
    if (code >= 80 && code <= 82) return "Rain showers"
    if (code >= 85 && code <= 86) return "Snow showers"
    if (code === 95) return "Thunderstorm"
    if (code >= 96 && code <= 99) return "Thunderstorm with hail"
    return ""
  }

  readonly property string icon: iconFor(weatherCode, isDay)
  readonly property string description: describe(weatherCode)

  // Giro regolare: un aggiornamento ogni 15 minuti, il primo all'avvio.
  Timer {
    interval: 15 * 60 * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  // Dopo un errore non si aspettano 15 minuti: un tentativo al minuto finche' non va.
  Timer {
    id: retry
    interval: 60 * 1000
    onTriggered: root.refresh()
  }

  // Link tornato su: richiesta immediata, senza aspettare retry o giro regolare.
  Connections {
    target: Net
    function onConnectedChanged() { if (Net.connected) root.refresh() }
  }
}
