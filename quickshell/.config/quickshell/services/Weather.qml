// Weather.qml
pragma Singleton

import Quickshell
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

  function iconFor(code) {
    if (code === 0) return "\u{f0599}";              // md-weather_sunny
    if (code >= 1 && code <= 2) return "\u{f015f}";  // md-cloud (pieno)
    if (code === 3) return "\u{f015f}";              // md-cloud (pieno)
    if (code === 45 || code === 48) return "\u{f0591}"; // md-weather_fog
    if (code >= 51 && code <= 57) return "\u{ef1c}"; // fa-cloud_rain (pieno)
    if (code >= 61 && code <= 67) return "\u{ef1c}"; // fa-cloud_rain (pieno)
    if (code >= 71 && code <= 77) return "\u{f0598}"; // md-weather_snowy
    if (code >= 80 && code <= 82) return "\u{ef1c}"; // fa-cloud_rain (pieno)
    if (code >= 85 && code <= 86) return "\u{f067f}"; // md-weather_snowy_rainy
    if (code >= 95 && code <= 99) return "\u{ef2c}"; // fa-cloud_bolt (pieno)
    return "\u{f0599}";
  }
  readonly property string icon: iconFor(weatherCode)

  Timer {
    interval: 15 * 60 * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }
}
