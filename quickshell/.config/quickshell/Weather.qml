// Weather.qml
pragma Singleton

import QtQuick

Singleton {
  id: root

  readonly property real latitude: 41.9
  readonly property real longitude: 12.5

  property real temperature: 0
  property int weatherCode: 0

  function refresh() {
    var xhr = new XMLHttpRequest();
    var url = "https://api.open-meteo.com/v1/forecast?latitude=" + latitude
             + "&longitude=" + longitude + "&current=temperature_2m,weather_code";

    xhr.onreadystatechange = function() {
      if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
        var data = JSON.parse(xhr.responseText);
        root.temperature = data.current.temperature_2m;
        root.weatherCode = data.current.weather_code;
      }
    }

    xhr.open("GET", url);
    xhr.send();
  }

  // --- QUESTA È LA PARTE NUOVA ---
  function iconFor(code) {
    if (code === 0) return "\uf00d";
    if (code >= 1 && code <= 2) return "\uf002";
    if (code === 3) return "\uf013";
    if (code === 45 || code === 48) return "\uf014";
    if (code >= 51 && code <= 57) return "\uf01c";
    if (code >= 61 && code <= 67) return "\uf019";
    if (code >= 71 && code <= 77) return "\uf01b";
    if (code >= 80 && code <= 82) return "\uf01a";
    if (code >= 85 && code <= 86) return "\uf01b";
    if (code >= 95 && code <= 99) return "\uf01e";
    return "\uf00d";
  }

  readonly property string icon: iconFor(weatherCode)
  // --- FINE PARTE NUOVA ---

  Timer {
    interval: 15 * 60 * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }
}
