// Audio.qml
pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris


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

  // Prima questa catena stava duplicata in VolumeWidget e in Dashboard.
  readonly property string icon: root.iconFor(root.volume, root.muted)

  function iconFor(vol, mut) {
    if (mut || vol <= 0) return Icons.volMuted
    if (vol < 0.34) return Icons.volLow
    if (vol < 0.67) return Icons.volMedium
    return Icons.volHigh
  }

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

  // ── Stream delle applicazioni ───────────────────────────────────────

  // Soprainsieme: comprende i flussi in entrata e i nodi non ancora
  // bound. E' questo che va dato al tracker, non la lista filtrata.
  readonly property var streamNodes:
    Pipewire.nodes.values.filter(n => n.isStream && n.audio)

  // Cio' che vede la UI: sola riproduzione, suoni di sistema esclusi.
  // media.class e' leggibile solo a nodo bound, quindi ready entra nel
  // filtro: e' la dipendenza che fa rivalutare il binding al momento giusto.
  readonly property var streams: root.streamNodes.filter(n =>
    n.ready
    && n.properties["media.class"] === "Stream/Output/Audio"
    && n.properties["media.role"] !== "event")

  // App che riscrivono il volume del proprio stream: per loro si passa da MPRIS.
  readonly property var mprisVolumeApps: ["spotify"]

  // Player MPRIS che possiede il volume di questo nodo, o null.
  function playerFor(node) {
    if (!node) return null
    const p = node.properties ?? ({})
    const keys = [p["application.name"], p["application.process.binary"]]
      .filter(k => k).map(k => k.toLowerCase())
    if (!keys.some(k => root.mprisVolumeApps.includes(k))) return null

    for (const pl of Mpris.players.values) {
      if (!pl.canControl || !pl.volumeSupported) continue
      const id = (pl.desktopEntry || pl.identity || "").toLowerCase()
      if (keys.includes(id)) return pl
    }
    return null
  }

  function volumeOf(node) {
    const pl = root.playerFor(node)
    return pl ? pl.volume : (node?.audio?.volume ?? 0)
  }

  function mutedOf(node)   { return node?.audio?.muted  ?? false }
  function percentOf(node) { return Math.round(root.volumeOf(node) * 100) }
  function iconOf(node)    { return root.iconFor(root.volumeOf(node), root.mutedOf(node)) }

  function setNodeVolume(node, v) {
    const c = Math.max(0, Math.min(1, v))
    // Volume interno del player: lo applica e lo ricorda lui, niente conflitti.
    const pl = root.playerFor(node)
    if (pl) { pl.volume = c; return }
    if (!node?.audio) return
    node.audio.volume = c
  }

  // Il mute resta su PipeWire: MPRIS non ha un concetto di mute.
  function toggleNodeMute(node) {
    if (!node?.audio) return
    node.audio.muted = !node.audio.muted
  }

  // Catena di ripiego: i giochi Proton e i client WebRTC raramente hanno
  // un application.name presentabile.
  function labelFor(node) {
    if (!node) return ""
    const p = node.properties ?? ({})
    return p["application.name"]
        || p["application.process.binary"]
        || node.description
        || node.name
  }

  // Nome di icona di sistema gia' risolto: "" se il tema non ce l'ha.
  function iconNameFor(node) {
    if (!node) return ""
    const p = node.properties ?? ({})
    const n = p["application.icon-name"] || p["application.process.binary"] || ""
    return n ? Quickshell.iconPath(n, true) : ""
  }

  // ── Senza questo, le proprieta' qui sopra restano congelate al valore
  //    iniziale: gli oggetti Pipewire nascono "unbound". Deve vivere
  //    quanto la sessione, ed e' l'unico motivo per cui tutto questo sta
  //    in un singleton e non dentro il widget. ─────────────────────────
  PwObjectTracker {
    objects: [root.sink]
  }

  // Tracker separato: il sink vive quanto la sessione, gli stream nascono
  // e muoiono con le applicazioni.
  PwObjectTracker {
    objects: root.streamNodes
  }
}
