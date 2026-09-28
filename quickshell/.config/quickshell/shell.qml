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
    active: Drawers.isLoaded("today")

    Drawer {
      name: "today"
      edge: "top"
      panelWidth: 800

      // Solo il bordo alto: il compositore centra in orizzontale, sotto l'orologio.
      anchors.top: true
      margins.top: 6

      Today {
        Layout.fillWidth: true
      }
    }
  }

  LazyLoader {
    active: Drawers.isLoaded("weather")

    Drawer {
      name: "weather"
      edge: "top"
      panelWidth: 1100

      // Come "today": solo il bordo alto, centrato sotto la pill dell'orologio.
      anchors.top: true
      margins.top: 6

      WeatherPage {
        Layout.fillWidth: true
      }
    }
  }


  LazyLoader {
    active: Drawers.isLoaded("wallpapers")

    Drawer {
      name: "wallpapers"
      edge: "center"

      // Striscia da bordo a bordo: le carte galleggiano sul desktop, senza fondo.
      anchors.left: true
      anchors.right: true
      showBackground: false

      // Frecce e invio: servono i tasti appena aperto.
      grabKeyboard: true

      // Ancorato solo ai lati: su layer-shell una superficie non ancorata
      // a top e bottom viene centrata in verticale dal compositore.

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
