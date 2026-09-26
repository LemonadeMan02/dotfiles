// shell.qml
import Quickshell
import QtQuick
import QtQuick.Layouts
import "./modules/bar"
import "./modules/drawer"
import "./modules/notifications"
import "./services"

Scope {
  // I singleton nascono al primo uso: questo li avvia e riallinea la preferenza di sistema.
  Component.onCompleted: ColorScheme.sync()

  Bar {}

  NotificationPopups {}

  // Legati a "loaded", non a "current": le finestre devono restare in vita
  // per tutta l'animazione di uscita e smontarsi solo dopo.
  LazyLoader {
    active: Drawers.isLoaded("launcher")

    Drawer {
      name: "launcher"
      edge: "bottom"
      panelWidth: 560

      // Un launcher vuole i tasti appena aperto, senza un click prima.
      grabKeyboard: true

      // Incollato al bordo inferiore: gli angoli bassi muoiono li' contro
      // e arrotondarli lascerebbe due spicchi di vuoto.
      anchors.bottom: true
      margins.bottom: 0
      bottomRadius: 0

      // Collegamento esplicito: qui i due oggetti sono entrambi in vista,
      // e non serve risalire la gerarchia con una attached property.
      onFocusReady: launcherContent.focusSearch()

      Launcher {
        id: launcherContent
        Layout.fillWidth: true
      }
    }
  }

  LazyLoader {
    active: Drawers.isLoaded("dashboard")

    Drawer {
      name: "dashboard"
      edge: "top"
      panelWidth: 340

      // Allineato al gruppo destro della barra: stesso margine.
      anchors.top: true
      anchors.right: true
      margins.top: 6
      margins.right: 10

      Dashboard {
        Layout.fillWidth: true
      }
    }
  }

  LazyLoader {
    active: Drawers.isLoaded("wallpapers")

    Drawer {
      name: "wallpapers"
      edge: "center"
      panelWidth: 900

      // Frecce e invio: servono i tasti appena aperto.
      grabKeyboard: true

      // Nessun anchor: su layer-shell una superficie non ancorata a lati
      // opposti viene centrata dal compositore. E' il posizionamento del
      // cassetto centrale, non una dimenticanza.

      onFocusReady: picker.focusStrip()

      WallpaperPicker {
        id: picker
        Layout.fillWidth: true
      }
    }
  }

  LazyLoader {
    active: Drawers.isLoaded("overview")

    Drawer {
      name: "overview"
      edge: "center"

      // 5 miniature da 260 piu' gli spazi: da tenere allineato a tileW in Overview.qml.
      panelWidth: 1360

      // Escape per chiudere: servono i tasti appena aperto.
      grabKeyboard: true

      onFocusReady: overview.focusOverview()

      Overview {
        id: overview
        Layout.fillWidth: true
      }
    }
  }
}
