// WorkspacesWidget.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../services"

RowLayout {
  id: root
  spacing: Theme.spacingS

  required property var screen

  property int count: 8

  // Stessa altezza dei chip di destra: la barra ha un solo ritmo verticale.
  property int chipSize: Theme.chipHeight
  property int chipSizeFocused: Theme.chipHeight + 20
  property int dotSize: 16

  // Velo del testo sulla pill: contrasta sempre, qualunque palette generi matugen.
  readonly property color tint:      Theme.withAlpha(Theme.foreground, 0.14)
  readonly property color tintHover: Theme.withAlpha(Theme.foreground, 0.24)

  // Assegnata a mano: un binding su monitorFor() dipenderebbe dal modello che tocca, loop.
  property HyprlandMonitor monitor: null

  function updateMonitor() {
    root.monitor = Hyprland.monitorFor(root.screen)
  }

  Component.onCompleted: root.updateMonitor()

  Connections {
    target: Hyprland.monitors
    function onValuesChanged() { root.updateMonitor() }
  }

  readonly property var activeWs: monitor ? monitor.activeWorkspace : null
  readonly property bool monitorFocused: monitor ? monitor.focused : false

  function goToWorkspace(id) {
    if (Hyprland.usingLua)
      Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })")
    else
      Hyprland.dispatch("workspace " + id)
  }

  Repeater {
    model: root.count

    delegate: Rectangle {
      id: chip
      required property int index

      readonly property int wsId: index + 1

      readonly property var ws: {
        for (const w of Hyprland.workspaces.values)
          if (w.id === chip.wsId) return w
        return null
      }

      // Confronto per nome: HyprlandMonitor e' un oggetto, il nome e' l'identita' stabile.
      readonly property bool here: ws !== null && ws.monitor !== null
                                   && root.monitor !== null
                                   && ws.monitor.name === root.monitor.name

      readonly property bool populated: here
      readonly property bool elsewhere: ws !== null && !here
      readonly property bool active: root.activeWs !== null
                                     && root.activeWs.id === chip.wsId
      readonly property bool focused: active && root.monitorFocused
      // Urgente anche se sta sull'altro monitor: e' proprio li' che serve vederlo.
      readonly property bool urgent: ws !== null && ws.urgent && !focused

      readonly property bool showsNumber: populated || active || urgent
      readonly property bool hovered: hover.hovered

      implicitHeight: root.chipSize
      implicitWidth: focused     ? root.chipSizeFocused
                   : showsNumber ? root.chipSize
                                 : root.dotSize

      // Angoli smussati ma lati dritti, come le pill.
      radius: Theme.radiusS
      antialiasing: true

      color: focused   ? Theme.accent
           : urgent    ? Theme.urgent
           : active    ? (hovered ? root.tint : "transparent")
           : populated ? (hovered ? root.tintHover : root.tint)
                       : (hovered ? root.tint : "transparent")

      // Attivo sul monitor senza focus: solo contorno, per distinguerlo dal focused.
      border.width: (active && !focused) ? 2 : 0
      border.color: Theme.accent

      // OutCubic invece di OutBack: il rimbalzo sulla larghezza fa tremare i vicini.
      Behavior on implicitWidth {
        NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutCubic }
      }
      Behavior on color {
        ColorAnimation { duration: Theme.durFast }
      }

      Text {
        anchors.centerIn: parent
        visible: chip.showsNumber
        text: chip.wsId
        font.family: Theme.fontFamily
        font.weight: Theme.weightBold
        font.pixelSize: Theme.fontM
        color: chip.focused ? Theme.onAccent
             : chip.urgent  ? Theme.onUrgent
                            : Theme.foreground

        Behavior on color {
          ColorAnimation { duration: Theme.durFast }
        }
      }

      // Pallino: grigio se vuoto, piu' chiaro se il workspace vive sull'altro monitor.
      Rectangle {
        anchors.centerIn: parent
        visible: !chip.showsNumber
        implicitWidth: 6
        implicitHeight: 6
        radius: 3
        antialiasing: true
        color: chip.elsewhere ? Theme.foregroundDim : Theme.muted
      }

      HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        onTapped: root.goToWorkspace(chip.wsId)
      }
    }
  }
}
