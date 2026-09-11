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
    if (code === 0) return "\ue30d";              // weather-day_sunny
    if (code >= 1 && code <= 2) return "\ue302";  // weather-day_cloudy
    if (code === 3) return "\ue312";              // weather-cloudy
    if (code === 45 || code === 48) return "\ue313"; // weather-fog
    if (code >= 51 && code <= 57) return "\ue31b"; // weather-sprinkle (pioviggine)
    if (code >= 61 && code <= 67) return "\ue318"; // weather-rain
    if (code >= 71 && code <= 77) return "\ue31a"; // weather-snow
    if (code >= 80 && code <= 82) return "\ue319"; // weather-showers (rovesci)
    if (code >= 85 && code <= 86) return "\ue31a"; // weather-snow
    if (code >= 95 && code <= 99) return "\ue31d"; // weather-thunderstorm
    return "\ue30d";
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
