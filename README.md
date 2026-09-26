# dotfiles

Config del desktop Hyprland, gestite con [GNU Stow](https://www.gnu.org/software/stow/).

## 1. Cosa copre

Da un'Arch Linux appena installata allo stato attuale:

- sessione **Hyprland** avviata da **uwsm**, login con **SDDM**;
- **Quickshell** come barra, launcher, notifiche e dashboard;
- colori generati da **matugen** a partire dallo sfondo (**awww**), condivisi da Quickshell, Hyprland e kitty;
- terminale **kitty** con **fish** e **starship** (la login shell resta bash);
- GPU **Nvidia** con il driver `nvidia-open`;
- rete con **systemd-networkd** e **systemd-resolved** (niente NetworkManager);
- audio con **PipeWire**, più Bluetooth e stampa.

Pacchetti Stow nel repo: `autostart fish hypr kitty matugen quickshell scripts starship systemd uwsm`.

Non copre l'installazione di Arch: partizioni, bootloader, kernel, microcode e firmware si scelgono durante l'installazione e dipendono dalla macchina.

### Prerequisiti

- Arch Linux installata con il kernel `linux`: `nvidia-open` funziona solo con quello (vedi sezione 4).
- Un utente normale con `sudo`.
- Rete già funzionante: la configurazione di systemd-networkd (`/etc/systemd/network/`) non è nel repo.
- Il repository `[multilib]` abilitato prima di installare i pacchetti: serve a Steam e a `lib32-nvidia-utils` (vedi sezione 3).

## 2. Clonare il repo

Il repo va in `~/dotfiles`: Stow collega i file nella cartella superiore (`~`) e i symlink sono relativi a quel percorso.

`git` serve prima della lista pacchetti, che sta nel repo:

```fish
sudo pacman -S --needed git
git clone https://github.com/LemonadeMan02/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Il clone via HTTPS non richiede chiavi SSH. Per fare push, una volta configurata la chiave:

```fish
git remote set-url origin git@github.com:LemonadeMan02/dotfiles.git
```

## 3. Pacchetti

### Abilitare `[multilib]`

Va fatto **prima** dell'installazione: senza, `lib32-nvidia-utils` e `steam` non si trovano e fallisce l'intera transazione.

In `/etc/pacman.conf` togli il `#` davanti alle due righe della sezione `[multilib]`:

```fish
sudoedit /etc/pacman.conf
```

Controlla il risultato:

```fish
grep -A1 '^\[multilib\]' /etc/pacman.conf
```

Le due righe devono uscire senza `#` davanti:

```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Poi aggiorna i database e il sistema:

```fish
sudo pacman -Syu
```

### Repo ufficiali

[`pkglist.txt`](pkglist.txt) ha un pacchetto per riga, divisi in gruppi. `sed` toglie commenti e righe vuote, e `-` fa leggere a pacman l'elenco da stdin (`man pacman`):

```fish
sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' pkglist.txt | sudo pacman -S --needed -
```

`--needed` salta quelli già installati, quindi il comando si può rilanciare.

### Helper AUR (yay)

yay non è nei repo ufficiali: la prima volta si compila a mano con `makepkg` (servono `git` e `base-devel`, già installati al passo prima):

```fish
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay && makepkg -si
cd ~/dotfiles
```

Se in `/etc/makepkg.conf` è attiva l'opzione `debug`, `makepkg -si` installa anche `yay-debug`: non serve, si può rimuovere con `sudo pacman -Rns yay-debug`.

### AUR

[`pkglist-aur.txt`](pkglist-aur.txt), stesso formato:

```fish
sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' pkglist-aur.txt | yay -S --needed -
```

Oggi la lista contiene solo yay, quindi il comando non installa niente: serve per i pacchetti AUR che si aggiungeranno.

## 4. Nvidia

I pacchetti sono nel gruppo Nvidia di `pkglist.txt`:

- `nvidia-open`: modulo per il kernel `linux`. Con altri kernel (`linux-lts`, `linux-zen`, …) serve invece `nvidia-open-dkms` più gli header del kernel (`linux-lts-headers`, …);
- `libva-nvidia-driver`: decodifica video in hardware (VA-API);
- `egl-wayland`: arriva già con `nvidia-utils`, è in lista perché la wiki di Hyprland lo richiede;
- `lib32-nvidia-utils`: driver a 32 bit per Steam.

Nessun parametro del kernel e nessun file in `/etc/modprobe.d`: con i driver attuali il DRM kernel mode setting che serve a Wayland è già attivo di default.

Le variabili d'ambiente per Nvidia (`LIBVA_DRIVER_NAME`, `__GLX_VENDOR_LIBRARY_NAME`, `CUDA_DISABLE_PERF_BOOST`) sono in `uwsm/.config/uwsm/env` e arrivano con Stow (sezione 5), commentate lì.

Dopo l'installazione riavvia, così si carica il modulo al posto di `nouveau`, poi controlla:

```fish
cat /sys/module/nvidia_drm/parameters/modeset   # Y
vainfo                                          # dalla sessione grafica: "Driver version" cita NVDEC
```

Riferimenti: [Arch Wiki — NVIDIA](https://wiki.archlinux.org/title/NVIDIA), [wiki.hypr.land — Nvidia](https://wiki.hypr.land/Nvidia/).

## 5. Collegare con Stow

Ogni cartella del repo è un pacchetto Stow: `stow <pacchetto>` crea in `~` i symlink verso i suoi file. I comandi vanno lanciati da `~/dotfiles`.

Prima crea `~/.config`: se manca, Stow collegherebbe l'intera cartella al primo pacchetto invece di crearla.

```fish
mkdir -p ~/.config
cd ~/dotfiles
```

### Pacchetti normali

Qui Stow può collegare la cartella intera (per esempio `~/.config/hypr` → repo), perché ci scrivono solo queste config:

```fish
stow -n -v fish hypr kitty matugen quickshell starship uwsm   # prova, non tocca niente
stow -v fish hypr kitty matugen quickshell starship uwsm
```

fish scrive `fish_variables` dentro `~/.config/fish`, quindi nel repo: è in `.gitignore`. Anche `funcsave` e `fish_config` (quando salva il prompt) scrivono in `~/.config/fish/functions`, cioè nel repo: quei file compaiono in `git status` e vanno committati o cancellati.

### Pacchetti con `--no-folding`

`~/.config/systemd/user`, `~/.config/autostart` e `~/.local/bin` sono cartelle in cui scrivono anche altri (`systemctl --user enable` crea le cartelle `*.wants/`, altre app aggiungono `.desktop` o eseguibili). Con `--no-folding` Stow crea cartelle vere e collega solo i singoli file; senza, quei file finirebbero nel repo.

```fish
stow -n -v --no-folding systemd autostart scripts   # prova
stow -v --no-folding systemd autostart scripts
systemctl --user daemon-reload
```

`daemon-reload` fa leggere a systemd le unit appena collegate (`awww.service`, `quickshell.service`); si abilitano nella sezione 7.

Non usare `stow */`: collegherebbe anche eventuali cartelle che non sono pacchetti.

### Conflitti

Se un file esiste già in `~` (per esempio una config di default), la prova con `-n` lo segnala come conflitto (`existing target`) e Stow non collega niente di quel comando: il conflitto annulla l'intera invocazione, anche per gli altri pacchetti elencati. Sposta da parte la cartella intera (così Stow può collegarla come le altre) e ripeti:

```fish
mv ~/.config/kitty ~/.config/kitty.bak
```

Evita `--adopt` alla cieca: sposta il file locale dentro il repo al posto di quello versionato. Se lo usi, controlla subito con `git diff` e ripristina i file sovrascritti con `git restore <file>`.

Riferimenti: `man stow`, [Arch Wiki — Dotfiles](https://wiki.archlinux.org/title/Dotfiles).

## 6. Servizi di sistema

Quelli abilitati su questa macchina, oltre ai default di systemd.

Rete, DNS e ora (se l'installazione li ha già abilitati, il comando non cambia niente):

```fish
sudo systemctl enable --now systemd-networkd systemd-resolved systemd-timesyncd
```

`systemd-networkd` abilita da solo anche `systemd-networkd-wait-online` e i suoi socket.

Con systemd-resolved, `/etc/resolv.conf` deve puntare al suo stub resolver:

```fish
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

Bluetooth, stampa e TRIM settimanale degli SSD:

```fish
sudo systemctl enable --now bluetooth.service cups.socket cups.path cups.service fstrim.timer
```

Login grafico, **senza** `--now` (partirebbe subito sopra la console; si usa dal riavvio, sezione 8):

```fish
sudo systemctl enable sddm.service
```

SDDM verrà sostituito da greetd: la procedura non è ancora in questo README.

`seatd` su questa macchina risulta abilitato, ma non serve: con SDDM la sessione passa da `systemd-logind`. Non si abilita.

## 7. Servizi utente

Partono con la sessione grafica: uwsm avvia `graphical-session.target` e questi servizi sono legati a quel target (`WantedBy=` e `PartOf=graphical-session.target`), quindi si fermano e ripartono con la sessione.

| Servizio | Da dove | Cosa fa |
|---|---|---|
| `quickshell.service` | repo (`systemd/`) | barra, launcher, notifiche, dashboard |
| `awww.service` | repo (`systemd/`) | demone dello sfondo |
| `hypridle.service` | pacchetto `hypridle` | da inattivo: blocco con hyprlock a 5 min, monitor spenti a 5 min e mezzo (`hypridle.conf`) |
| `hyprpolkitagent.service` | pacchetto `hyprpolkitagent` | finestra per le richieste di password polkit |

Si abilitano dopo Stow (sezione 5), **senza** `--now`: fuori dalla sessione grafica non partirebbero (`Requisite=graphical-session.target`, e hypridle e hyprpolkitagent richiedono `WAYLAND_DISPLAY`).

```fish
systemctl --user enable quickshell.service awww.service hypridle.service hyprpolkitagent.service
```

Per PipeWire, WirePlumber, gnome-keyring e xdg-user-dirs non servono comandi: i loro pacchetti li abilitano per tutti gli utenti.

Log di un servizio: `journalctl --user -u quickshell`.

## 8. Primo login

Riavvia:

```fish
systemctl reboot
```

Nella schermata di SDDM scegli la sessione **Hyprland (uwsm-managed)**, non "Hyprland": solo la prima avvia Hyprland tramite uwsm, che carica `~/.config/uwsm/env` e attiva `graphical-session.target`, e quindi i servizi della sezione 7. SDDM ricorda l'ultima sessione scelta.

Per controllare che la sessione sia quella giusta, da kitty:

```fish
systemctl --user is-active graphical-session.target   # active
```

Al primo avvio i colori sono quelli di ripiego: lo schema di matugen si genera nella sezione 9.

## 9. Stato fuori dal repo

Questi file non sono versionati: si creano da soli o al primo uso.

| File | Chi lo crea |
|---|---|
| `~/.local/state/quickshell/config.json` | Quickshell al primo avvio, con i default (tema scuro, colori dinamici, sfondi da `~/Wallpapers`) |
| `~/.local/state/quickshell/colors.json` | matugen, al primo sfondo scelto |
| `~/.local/state/hypr/colors.lua` | matugen, idem |
| `~/.local/state/kitty/colors.conf` | matugen, idem |

### Sfondi e colori

Gli sfondi non sono nel repo. Crea la cartella e copiaci le immagini:

```fish
mkdir -p ~/Wallpapers
```

Poi da Quickshell: launcher (SUPER+Space) → **Wallpaper**, e scegli un'immagine. Quickshell lancia `matugen image <file> -m dark`, che imposta lo sfondo con awww e scrive i tre file dei colori; Hyprland e kitty si ricaricano da soli (`post_hook` in `matugen/.config/matugen/config.toml`). Ai login successivi awww ripristina l'ultimo sfondo.

Per usare un'altra cartella, cambia `wallpaperDir` in `config.json`.

### Cartella Immagini

Lo script `screenshot` salva in `$(xdg-user-dir PICTURES)/Screenshots`. Le cartelle utente (`~/Pictures`, …) le crea `xdg-user-dirs.service` al login; per crearle subito:

```fish
xdg-user-dirs-update
```

## 10. Adattamenti per un'altra macchina

Queste config contengono valori legati a questo PC. Su un'altra macchina vanno cambiati a mano.

### Monitor — `hypr/.config/hypr/monitors.lua`

Due monitor identificati per descrizione (`desc:Dell Inc. AW3225QF`, `desc:LG Electronics LG ULTRAGEAR`), con risoluzione, posizione e scala. Descrizioni e modi disponibili:

```fish
hyprctl monitors all
```

Da `monitors.ordered` dipendono anche i workspace: 5 per monitor, 1-5 sul primo e 6-10 sul secondo. Con un numero diverso di monitor vanno adattati `monitors.ordered`, i set di tasti in `hypr/.config/hypr/workspaces.lua` (riga dei numeri per il primo, tastierino per il secondo) e, se cambia il numero di workspace per monitor, anche `perMonitor` in `quickshell/.config/quickshell/services/Workspaces.qml`.

### Interfaccia di rete — `quickshell/.config/quickshell/services/Net.qml`

`iface` è fisso su `enp3s0`: con un altro nome il widget della rete resta "down". Il nome giusto:

```fish
ip -br link
```

### Meteo — `quickshell/.config/quickshell/services/Weather.qml`

`latitude` e `longitude` (41.9, 12.5: Roma) sono le coordinate passate a Open-Meteo.

### Tastiera — `hypr/.config/hypr/hyprland.lua`

`kb_layout = "gb"` con `kb_variant = "extd"`. Vale solo dentro Hyprland: console e SDDM usano il layout di sistema (`localectl`).

## 11. Pacchetti sostituiti

Questi pacchetti c'erano in passato e non vanno reinstallati: il loro lavoro ora lo fa qualcos'altro, e alcuni entrerebbero in conflitto.

| Pacchetto | Sostituito da | Perché non reinstallarlo |
|---|---|---|
| `dunst` | Quickshell (`services/Notifications.qml`) | sul bus D-Bus un solo processo può essere il server delle notifiche (`org.freedesktop.Notifications`); con dunst installato i due se lo contenderebbero, per esempio mentre Quickshell si riavvia |
| `polkit-kde-agent` | `hyprpolkitagent` (servizio utente, sezione 7) | in una sessione si registra un solo agente polkit: due agenti si contendono le richieste di password |
| `playerctl` | Quickshell (`services/Media.qml`) | i tasti multimediali sono `GlobalShortcut` di Quickshell che comandano il player via MPRIS; nessun processo esterno a ogni pressione |
| `wofi` | launcher di Quickshell (SUPER+Space) | nessuna config lo usa più: sarebbe solo un secondo launcher |

Se uno di questi arriva come dipendenza di un altro pacchetto, controlla che non parta. dunst in particolare non ha bisogno di essere avviato: si attiva da solo via D-Bus alla prima notifica, se in quel momento nessun altro è il server.

## 12. Verifica finale

Tutti comandi in sola lettura, da `~/dotfiles` e dalla sessione Hyprland.

Pacchetti: `pacman -T` stampa i pacchetti della lista che **non** sono installati, quindi nessun output = tutto a posto.

```fish
sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' pkglist.txt | pacman -T -
sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' pkglist-aur.txt | pacman -T -
```

Servizi di sistema (sezione 6), tutti `enabled`:

```fish
systemctl is-enabled sddm systemd-networkd systemd-resolved systemd-timesyncd bluetooth cups.socket cups.path cups.service fstrim.timer
```

Servizi utente (sezione 7), tutti `active`:

```fish
systemctl --user is-active quickshell awww hypridle hyprpolkitagent
```

Symlink di Stow: il primo comando elenca quelli verso il repo, il secondo quelli verso il repo ma rotti (nessun output = nessuno rotto):

```fish
find ~/.config ~/.local/bin -maxdepth 4 -type l -lname '*dotfiles*' -printf '%p -> %l\n'
find ~/.config ~/.local/bin -maxdepth 4 -xtype l -lname '*dotfiles*'
```

Config di Hyprland, nessun errore:

```fish
hyprctl configerrors
```

## 13. Fonti

- [Arch Wiki — pacman](https://wiki.archlinux.org/title/Pacman) e [pacman/Tips and tricks](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks) (liste di pacchetti), `man pacman`
- [Arch Wiki — Arch User Repository](https://wiki.archlinux.org/title/Arch_User_Repository) (`makepkg`)
- [Arch Wiki — Dotfiles](https://wiki.archlinux.org/title/Dotfiles), [manuale di GNU Stow](https://www.gnu.org/software/stow/manual/), `man stow`
- [Arch Wiki — systemd/User](https://wiki.archlinux.org/title/Systemd/User)
- [Arch Wiki — Universal Wayland Session Manager](https://wiki.archlinux.org/title/Universal_Wayland_Session_Manager)
- [Arch Wiki — NVIDIA](https://wiki.archlinux.org/title/NVIDIA)
- [Arch Wiki — systemd-networkd](https://wiki.archlinux.org/title/Systemd-networkd) e [systemd-resolved](https://wiki.archlinux.org/title/Systemd-resolved)
- [wiki.hypr.land](https://wiki.hypr.land/), in particolare [Nvidia](https://wiki.hypr.land/Nvidia/)
- [Documentazione di Quickshell](https://quickshell.org/docs)
