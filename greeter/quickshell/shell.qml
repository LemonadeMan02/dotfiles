// shell.qml del greeter: una finestra per schermo, login solo su quello principale
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Greetd
import QtQuick
import QtQuick.Effects
import "services"


ShellRoot {
  id: root

  // Output con orologio e password; gli altri mostrano solo lo sfondo
  readonly property string mainScreen: "DP-1"

  // Utente da autenticare: lo passa il comando di greetd, niente campo nome
  readonly property string user: Quickshell.env("GREETER_USER") ?? ""

  // Dopo il login: la stessa sessione "Hyprland (uwsm-managed)" di SDDM.
  // UWSM_SILENT_START: uwsm non scrive i suoi messaggi sulla console mentre la sessione parte
  readonly property var sessionCommand: ["env", "UWSM_SILENT_START=1", "uwsm", "start", "hyprland.desktop"]

  // Prova: fuori da greetd, o con GREETER_TEST=1 sotto fakegreet. Tastiera non esclusiva, Esc chiude
  readonly property bool testMode: !Greetd.available || Quickshell.env("GREETER_TEST") === "1"

  // Stato dell'interfaccia: Greetd.state non dice com'e' andato l'ultimo tentativo
  property bool busy: false        // in attesa di greetd: campo bloccato, bordo giallo
  property bool failed: false      // ultimo tentativo fallito: bordo rosso
  property bool awaiting: false    // greetd ha fatto una domanda e aspetta la risposta
  property string message: ""      // riga sotto il campo
  property string prompt: "Password"
  property bool echo: false
  // Login riuscito: gli schermi sfumano nel nero prima di lasciare il posto alla sessione
  property bool leaving: false
  // Password scritta prima che greetd la chieda: va spedita al primo prompt
  property var answer: null

  // Gli id dentro Variants non si vedono da qui: il campo ascolta questo segnale per la scossa
  signal rejected()

  // Spegni e riavvia. In prova solo il log: dal desktop spegnerebbe davvero
  function power(cmd) {
    if (testMode) {
      console.log("greeter: prova, non eseguo", JSON.stringify(cmd))
      return
    }
    Quickshell.execDetached(cmd)
  }

  function reset() {
    busy = false
    // Lancio fallito (onError dopo readyToLaunch): il greeter torna visibile
    leaving = false
    awaiting = false
    answer = null
    prompt = "Password"
    echo = false
  }

  function fail(text) {
    reset()
    failed = true
    message = text
    rejected()
  }

  // Chiamata dal campo, che poi si svuota da solo
  function submit(text) {
    if (!Greetd.available) {
      console.log("greeter: prova senza greetd, invio ignorato")
      return
    }

    if (user === "") {
      fail("GREETER_USER non impostato")
      return
    }

    failed = false
    message = ""
    busy = true

    if (awaiting) {
      awaiting = false
      Greetd.respond(text)
    } else if (Greetd.state === GreetdState.Inactive) {
      answer = text
      Greetd.createSession(user)
    } else {
      // Sessione rimasta a meta' da un tentativo precedente: si chiude e si riprova
      console.warn("greeter: sessione in stato", Greetd.state, "senza domande aperte, annullo")
      Greetd.cancelSession()
      fail("Riprova")
    }
  }

  Connections {
    target: Greetd

    function onStateChanged() {
      console.log("greeter: stato", Greetd.state)
    }

    function onAuthMessage(message, error, responseRequired, echoResponse) {
      console.log("greeter: messaggio", JSON.stringify(message),
                  "errore", error, "risposta", responseRequired, "eco", echoResponse)

      if (!responseRequired) {
        root.message = message
        root.failed = error
        return
      }

      // Primo prompt: la password e' gia' stata scritta
      if (root.answer !== null) {
        const a = root.answer
        root.answer = null
        Greetd.respond(a)
        return
      }

      // Domande successive (es. secondo fattore): si mostrano nel campo e si aspetta
      root.prompt = message.trim().replace(/:$/, "")
      root.echo = echoResponse
      root.awaiting = true
      root.busy = false
    }

    function onAuthFailure(message) {
      console.log("greeter: autenticazione fallita:", message)
      root.fail("Password errata")
    }

    function onError(error) {
      console.warn("greeter: errore di greetd:", error)
      root.fail(error)
    }

    function onReadyToLaunch() {
      console.log("greeter: avvio", JSON.stringify(root.sessionCommand))
      root.message = "Avvio della sessione…"
      root.leaving = true
      launchTimer.start()
    }
  }

  // Il lancio aspetta la fine della dissolvenza: dopo restano solo console e sessione, nere.
  // La sessione riparte dal nero con lo stesso sfondo sfocato (quickshell/.config/quickshell/intro)
  Timer {
    id: launchTimer
    interval: Theme.durLeave
    // Quickshell esce da solo a sessione avviata
    onTriggered: Greetd.launch(root.sessionCommand)
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: win

      required property var modelData
      readonly property bool isMain: modelData.name === root.mainScreen

      screen: modelData
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      // Nero come la console e Hyprland prima del primo fotogramma: lo sfondo entra da qui
      color: "black"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "greeter"
      // Exclusive solo sotto greetd: in prova un bug non ti blocca la tastiera
      WlrLayershell.keyboardFocus: !win.isMain ? WlrKeyboardFocus.None
                                 : root.testMode ? WlrKeyboardFocus.OnDemand
                                 : WlrKeyboardFocus.Exclusive

      // Sfondo della sessione sfocato e scurito, come hyprlock; senza copia resta il colore pieno.
      // Decodificato a meta' misura: sotto la sfocatura non si vede, e due schermi pesano meno
      Image {
        id: wall
        anchors.fill: parent
        source: Theme.wallpaperUrl
        sourceSize: Qt.size(win.width / 2, win.height / 2)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
      }

      Item {
        anchors.fill: parent
        // Entra in dissolvenza a decodifica finita (o fallita, senza copia), invece di comparire a scatto
        opacity: wall.status === Image.Ready || wall.status === Image.Error ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: Theme.durSlow } }

        // Ripiego senza sfondo: il colore pieno
        Rectangle {
          anchors.fill: parent
          visible: wall.status !== Image.Ready
          color: Theme.background
        }

        Item {
          anchors.fill: parent
          visible: wall.status === Image.Ready

          MultiEffect {
            anchors.fill: parent
            source: wall
            blurEnabled: true
            blur: 1.0
            blurMax: 48
            // Senza, i bordi sfocati sfumano verso il trasparente
            autoPaddingEnabled: false
          }

          Rectangle {
            anchors.fill: parent
            color: Theme.scrim
            opacity: Theme.scrimOpacity
          }
        }
      }

      // Riavvia e spegni in basso a destra, solo sullo schermo principale
      Row {
        visible: win.isMain
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.spacingL * 2
        spacing: Theme.spacingM

        PowerButton {
          icon: "\uead2" // nf-md-restart
          onActivated: root.power(["systemctl", "reboot"])
        }

        PowerButton {
          icon: "\uf011" // nf-md-power
          onActivated: root.power(["systemctl", "poweroff"])
        }
      }

      Column {
        visible: win.isMain
        anchors.centerIn: parent
        spacing: Theme.spacingM
        // Al login orologio e campo si allontanano per primi, poi lo sfondo va nel nero
        opacity: root.leaving ? 0 : 1
        scale: root.leaving ? 0.94 : 1

        Behavior on opacity { NumberAnimation { duration: Theme.durSlow } }
        Behavior on scale { NumberAnimation { duration: Theme.durSlow; easing.type: Easing.InCubic } }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: Qt.formatDateTime(clock.date, "HH:mm")
          color: Theme.foreground
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontClock
          font.weight: Theme.weightBold
        }

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
          color: Theme.foregroundDim
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontDate
          font.weight: Theme.weightNormal
        }

        // Stacco fra data e campo, come i position di hyprlock
        Item { width: 1; height: Theme.spacingL * 4 }

        Rectangle {
          id: field
          anchors.horizontalCenter: parent.horizontalCenter
          width: Theme.fieldWidth
          height: Theme.fieldHeight
          radius: Theme.radiusM
          color: Theme.surface
          border.width: Theme.fieldBorder
          // Stessi ruoli di hyprlock: outer, check_color in attesa, fail_color all'errore
          border.color: root.failed ? Theme.urgent
                      : root.busy ? Theme.pending
                      : Theme.accent

          Behavior on border.color { ColorAnimation { duration: 150 } }

          // Scossa al rifiuto, solo in orizzontale
          SequentialAnimation {
            id: shake
            loops: 2
            NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -10; duration: 40 }
            NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 10; duration: 80 }
            NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 0; duration: 40 }
          }

          Connections {
            target: root
            function onRejected() { shake.restart() }
          }

          TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingL
            anchors.rightMargin: Theme.spacingL
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            echoMode: root.echo ? TextInput.Normal : TextInput.Password
            passwordCharacter: "•"
            readOnly: root.busy
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontM
            font.weight: Theme.weightBold
            clip: true
            focus: true

            // Niente cursore, come hyprlock: i pallini bastano a dare riscontro
            cursorDelegate: Item {}

            Component.onCompleted: forceActiveFocus()

            // Il rosso resta finche' non si ricomincia a scrivere
            onTextChanged: if (length > 0 && root.failed) {
              root.failed = false
              root.message = ""
            }

            // Prova: chiude. Sotto greetd: annulla una domanda rimasta aperta
            Keys.onEscapePressed: {
              if (root.testMode) {
                Qt.quit()
              } else if (root.awaiting) {
                Greetd.cancelSession()
                root.reset()
              }
            }

            // readOnly non ferma Invio: il controllo su busy serve anche qui
            onAccepted: if (!root.busy) {
              root.submit(text)
              text = ""
            }
          }

          Text {
            anchors.centerIn: parent
            visible: input.length === 0 && !root.busy
            text: root.prompt
            color: Theme.foregroundDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontM
            font.weight: Theme.weightNormal
          }
        }

        // Altezza fissa: comparendo il messaggio non sposta orologio e campo
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          height: Theme.fontM * 2
          verticalAlignment: Text.AlignVCenter
          text: root.message
          color: root.failed ? Theme.urgent : Theme.foregroundDim
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontM
          font.weight: Theme.weightNormal
        }
      }

      // Sopra tutto: al login il greeter sfuma nel nero, senza stacco verso la sessione
      Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.leaving ? 1 : 0
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: Theme.durLeave; easing.type: Easing.InQuad } }
      }
    }
  }
}
