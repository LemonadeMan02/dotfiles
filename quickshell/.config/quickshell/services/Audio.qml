// Audio.qml
pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire


Singleton {
  id: root

  // ── Il nodo. Puo' diventare null quando cambi dispositivo di uscita,
  //    quindi ogni accesso qui sotto e' protetto. ──────────────────────
  readonly property PwNode sink: Pipewire.defaultAudioSink

  // ── Cio' che vede il resto della barra. Il widget non importa mai
  //    Pipewire: parla solo con queste quattro cose. ──────────────────
  readonly property bool ready:  sink?.ready ?? false
  readonly property real volume: sink?.audio?.volume ?? 0
  readonly property bool muted:  sink?.audio?.muted  ?? false

  // Comodo per il display: 0.37 -> 37
  readonly property int percent: Math.round(volume * 100)

  function setVolume(v) {
    if (!sink?.audio) return
    // PipeWire accetta volumi oltre 1.0 (sovramplificazione). Senza
    // questo clamp, lo scroll del mouse ti porta a 3.0 e ti spacca le
    // orecchie.
    sink.audio.volume = Math.max(0, Math.min(1, v))
  }

  function stepVolume(delta) {
    setVolume(root.volume + delta)
  }

  function toggleMute() {
    if (!sink?.audio) return
    sink.audio.muted = !sink.audio.muted
  }

  // ── Senza questo, le proprieta' qui sopra restano congelate al valore
  //    iniziale: gli oggetti Pipewire nascono "unbound". Deve vivere
  //    quanto la sessione, ed e' l'unico motivo per cui tutto questo sta
  //    in un singleton e non dentro il widget. ─────────────────────────
  PwObjectTracker {
    objects: [root.sink]
  }
}
