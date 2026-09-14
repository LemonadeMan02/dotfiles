// shell.qml
import Quickshell
import "./modules/bar"
import "./modules/drawer"
import "./services"

Scope {
  Bar {}

  // Legato a "loaded", non a "visible": la finestra deve restare in vita
  // per tutta l'animazione di uscita e smontarsi solo dopo.
  LazyLoader {
    active: Drawers.loaded
    DrawerWindow {}
  }
}
