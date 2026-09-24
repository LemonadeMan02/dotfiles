// Weather.qml
pragma Singleton

import Quickshell
import QtQuick


Singleton {
  id: root

  readonly property real latitude: 41.9
  readonly property real longitude: 12.5

  // False finche' non arriva la prima risposta valida: 0 gradi non e' "nessun dato".
  property bool ready: false

  property real temperature: 0
  property int weatherCode: 0
  property bool isDay: true

  function refresh() {
    const xhr = new XMLHttpRequest()
    const url = "https://api.open-meteo.com/v1/forecast?latitude=" + root.latitude
              + "&longitude=" + root.longitude
              + "&current=temperature_2m,weather_code,is_day"

    xhr.onreadystatechange = function() {
      if (xhr.readyState !== XMLHttpRequest.DONE) return

      // status 0 = rete assente o DNS fallito: stesso trattamento di un errore HTTP.
      if (xhr.status !== 200) {
        console.warn("Weather: richiesta fallita, status", xhr.status)
        retry.restart()
        return
      }

      try {
        const data = JSON.parse(xhr.responseText)
        root.temperature = data.current.temperature_2m
        root.weatherCode = data.current.weather_code
        root.isDay = data.current.is_day === 1
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

  // Codici WMO 4677, come esposti da Open-Meteo nel campo weather_code.
  function iconFor(code) {
    // Sereno e quasi sereno: unici due casi in cui il sole si vede davvero,
    // quindi gli unici che hanno senso alternare giorno/notte.
    if (code === 0)  return root.isDay ? Icons.wClear  : Icons.wClearNight
    if (code === 1)  return root.isDay ? Icons.wClear  : Icons.wClearNight
    if (code === 2)  return root.isDay ? Icons.wPartly : Icons.wPartlyNight

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

  readonly property string icon: iconFor(weatherCode)

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
