# Piano: lista pacchetti versionata + README di installazione

## Contesto

Il repo `~/dotfiles` (GNU Stow, 10 pacchetti: `autostart fish hypr kitty matugen quickshell scripts starship systemd uwsm`) versiona le config ma non ricorda cosa installare e attivare. Obiettivo: una lista pacchetti curata (repo ufficiali + AUR, installabile con un solo `pacman -S --needed`) e un `README.md` che porti un'Arch pulita allo stato attuale.

**Limite importante:** lavoro in un container cloud con un clone del repo, non sul tuo PC. Non posso eseguire `pacman -Q…`, `systemctl` o `ls ~` sul tuo sistema: tutto lo stato reale me lo devi incollare tu (comandi al passo 0, tutti in sola lettura e compatibili con fish).

## Cosa ho già ricavato dalle config (da confermare con lo stato reale)

| Scopo | Pacchetti dedotti | Da dove |
|---|---|---|
| Sessione/compositor | hyprland, uwsm, sddm, xdg-desktop-portal-hyprland, hypridle, hyprlock, hyprpolkitagent | `hypr/`, `uwsm/`, `autostart.lua` |
| Shell desktop/temi | quickshell, matugen, awww, xdg-desktop-portal-gtk (+ gsettings) | `quickshell/`, `matugen/config.toml`, `ColorScheme.qml` |
| Font | ttf-jetbrains-mono (hyprlock, Theme.fontFamily), ttf-jetbrains-mono-nerd (kitty, icone) | `hyprlock.conf`, `Theme.qml`, `kitty.conf` |
| Terminale/CLI | kitty, fish, starship, zoxide, fzf, eza, bat | `kitty.conf`, `fish/conf.d/*` |
| Screenshot | grim, slurp, wl-clipboard, jq (usato dallo script), libnotify, xdg-user-dirs | `scripts/.local/bin/screenshot` |
| Audio | pipewire, pipewire-pulse, wireplumber (`wpctl`) | `keybindings.lua`, `Audio.qml` |
| Rete | systemd-networkd (+ resolved?), niente NetworkManager | `Net.qml` (iface `enp3s0` fissa) |
| Nvidia | nvidia-open(-dkms?), nvidia-utils, libva-nvidia-driver, lib32-nvidia-utils se Steam | `uwsm/env` |
| App | firefox, dolphin, spotify-launcher, discord, steam | `keybindings.lua`, `autostart.lua`, commento Xwayland |
| Portali e integrazione (richiesti dall'utente) | xdg-desktop-portal, qt5-wayland, qt6-wayland, gsettings-desktop-schemas; egl-wayland nel gruppo Nvidia — nei dubbi se già dipendenze | richiesta utente |
| Diagnostica (gruppo separato, decide l'utente) | libva-utils, wev | richiesta utente |
| Da chiarire | system-config-printer/cups (c'è `print-applet.desktop` che lo nasconde) | `autostart/` |

Pacchetti da **non** reintrodurre: dunst, polkit-kde-agent, playerctl.

## Passo 0 — Stato reale (lo esegui tu, mi incolli l'output)

```fish
pacman -Qqen                      # espliciti, repo ufficiali
pacman -Qqem                      # espliciti, AUR/foreign (mostra anche l'helper: paru/yay)
pacman -Qqent                     # espliciti non richiesti da altri: la differenza con -Qqen = candidati dipendenze
systemctl list-unit-files --state=enabled --no-pager
systemctl --user list-unit-files --state=enabled --no-pager
find ~/.config ~/.local/bin -maxdepth 4 -type l -lname '*dotfiles*' -printf '%p -> %l\n'
grep -A2 '^\[multilib\]' /etc/pacman.conf
cat /proc/cmdline; ls /etc/modprobe.d /etc/sddm.conf.d 2>/dev/null
getent passwd $USER | cut -d: -f7
xdg-user-dir PICTURES; ls ~/.local/state/quickshell ~/.local/state/hypr ~/.local/state/kitty
```

Da qui: classificazione proposta + **elenco esplicito dei pacchetti dubbi** su cui decidi tu.

## Struttura dei file (tutti in radice, fuori dai pacchetti Stow)

- `pkglist.txt` — repo ufficiali
- `pkglist-aur.txt` — AUR
- `README.md` — installazione

In radice e come file (non cartelle), così un `stow */` non li tratta mai come pacchetti.

**Formato lista:** un pacchetto per riga, sezioni `# ── Sessione e compositor ──`, commento breve a fine riga solo per i non ovvi (`libva-nvidia-driver  # VA-API su Nvidia, vedi uwsm/env`). Installazione (funziona in bash e fish, `-` = target da stdin, vedi `man pacman`):

```fish
sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' pkglist.txt | sudo pacman -S --needed -
```

**Gruppi:** Base e bootstrap (git, stow, base-devel) · Nvidia · Sessione e compositor · Shell desktop e colori · Font · Portali e integrazione desktop · Audio · Rete · Terminale e CLI · Screenshot · App · Diagnostica · (eventuali altri emersi dal passo 0).

## Indice del README

1. **Cosa copre** e prerequisiti (Arch base, utente con sudo, multilib se serve)
2. **Clonare il repo** in `~/dotfiles`
3. **Pacchetti** — repo ufficiali, bootstrap dell'helper AUR (makepkg), lista AUR
4. **Nvidia** — moduli/parametri solo se risultano dal passo 0 (wiki.hypr.land/Nvidia, Arch Wiki NVIDIA)
5. **Collegare con Stow** — comando per pacchetto; `systemd autostart scripts` con `--no-folding` perché `~/.config/systemd/user`, `~/.config/autostart` e `~/.local/bin` sono cartelle in cui scrivono anche altri (es. `systemctl --user enable` crea `*.wants/`, altre app aggiungono `.desktop` o eseguibili): senza, Stow collegherebbe l'intera cartella e quei file finirebbero nel repo. Flag degli altri pacchetti secondo lo stato reale. Gestione conflitti (`stow -n` prima, mai `--adopt` alla cieca). Dopo `stow --no-folding systemd`: `systemctl --user daemon-reload`, poi l'attivazione dei servizi.
6. **Servizi di sistema** — dallo stato reale (sddm, systemd-networkd/resolved, …); nota: SDDM verrà sostituito da greetd (senza procedura)
7. **Servizi utente** — quickshell, awww (dal repo), hypridle, hyprpolkitagent (dai pacchetti); legati a `graphical-session.target` di uwsm
8. **Primo login** — SDDM → "Hyprland (uwsm-managed)"
9. **Stato fuori dal repo** — `config.json` (Quickshell lo crea coi default al primo avvio), `colors.json` + `~/.local/state/hypr/colors.lua` + `~/.local/state/kitty/colors.conf` (primo `matugen image`), `~/Wallpapers`, `xdg-user-dirs-update` per Immagini
10. **Adattamenti per un'altra macchina** — `monitors.lua`, iface in `Net.qml`, coordinate in `Weather.qml`, layout tastiera
11. **Pacchetti sostituiti** — dunst, polkit-kde-agent, playerctl: perché non vanno reinstallati
12. **Verifica finale** — `pacman -T` sulla lista (vuoto = tutto installato), `systemctl --user is-active …`, `systemctl is-enabled …`, symlink presenti, `hyprctl configerrors` vuoto
13. **Fonti** — Arch Wiki (pacman, pacman/Tips and tricks, Stow, systemd/User, uwsm, NVIDIA), wiki.hypr.land, `man pacman`, `man stow`

## Script check-packages.sh (approvato, ultimo passo dopo il README)

`check-packages.sh` in radice: (a) in lista ma non installati (`pacman -T`), (b) espliciti installati ma non in lista (`pacman -Qqe` meno le due liste), (c) pacchetti AUR finiti nella lista ufficiale e viceversa. Solo lettura.

## Cose strane notate nelle config (non le tocco)

- `Net.qml` ha l'interfaccia `enp3s0` fissa: su un'altra macchina il widget rete resta "down".
- `hyprlock.conf` usa colori Catppuccin statici (già noto dal commento), mentre il resto segue matugen.
- `keybindings.lua` usa `dolphin` (app KDE): senza tema Qt/portale KDE può apparire spoglio; da valutare nei dubbi.

## Modalità di lavoro

Un file/sezione per volta: te lo mostro, lo approvi, ti propongo il commit nello stile `area: descrizione` (es. `pacchetti: lista curata repo ufficiali e AUR`, `readme: installazione da Arch pulita`). Nessun sudo/pacman/systemctl/stow/git commit da parte mia.

**Ordine:** passo 0 → pkglist.txt → pkglist-aur.txt → README a sezioni → check-packages.sh.

**Dove si lavora:** sessione sul PC dell'utente; lo stato si legge in sola lettura coi comandi del passo 0. l'ideale è riprendere in una sessione sul tuo PC (Claude Desktop, oppure `claude remote-control` lanciato in `~/dotfiles`, che poi compare nell'app Claude Code): lì posso leggere lo stato reale da solo e tu committi in locale. Se restiamo qui nel cloud, mi incolli l'output del passo 0 e i file approvati li riporti tu sul PC.

## Verifica

- Sintassi lista: il comando `sed …` in un container produce solo nomi, nessun commento né riga vuota.
- Sul tuo PC: `sed … pkglist.txt | pacman -T -` non stampa nulla (tutto installato) e ogni pacchetto esiste nei repo (`pacman -Si`).
- README: rileggo ogni comando contro fish e contro lo stato che mi hai incollato.
