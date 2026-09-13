// shell.qml
import Quickshell
import "./modules/bar"
import "./modules/drawer"
import "./services"

Scope {
  Bar {}

  LazyLoader {
    active: Drawers.visible
    DrawerWindow {}
  }
}
