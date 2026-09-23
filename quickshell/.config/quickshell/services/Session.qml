// Session.qml
pragma Singleton

import Quickshell


Singleton {
  id: root

  // Solo nomi di comandi, nessuna logica: si sostituiscono senza toccare la UI.
  // Il lock passa da logind: hypridle lo riceve e lancia hyprlock, un solo ingresso.
  readonly property var lockCmd:     ["loginctl", "lock-session"]
  readonly property var sleepCmd:    ["systemctl", "suspend"]
  readonly property var rebootCmd:   ["systemctl", "reboot"]
  readonly property var shutdownCmd: ["systemctl", "poweroff"]

  // Fire-and-forget: il processo sopravvive alla shell. Process servirebbe
  // solo se dovessimo leggerne l'output o l'exit code.
  function run(cmd) { Quickshell.execDetached(cmd) }

  function lock()     { root.run(root.lockCmd) }
  function sleep()    { root.run(root.sleepCmd) }
  function reboot()   { root.run(root.rebootCmd) }
  function shutdown() { root.run(root.shutdownCmd) }
}
