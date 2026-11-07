#!/bin/sh
# Da un'Arch appena installata allo stato del repo: README, sezioni 3-7.
# Si puo' rilanciare: ogni passo salta quello che e' gia' fatto.
# Da lanciare come utente normale (con sudo), dal TTY o da una sessione qualsiasi.
# Restano a mano: sfondi, calendario Google, chiave SSH (README, sezioni 8-9).
set -eu

# Pacchetti Stow (README, sezione 5)
STOW="bash dolphin fish hypr khal kitty matugen quickshell starship uwsm vdirsyncer"
STOW_NO_FOLDING="systemd autostart scripts"

# Servizi (README, sezioni 6 e 7)
SYSTEM_UNITS="systemd-networkd systemd-resolved systemd-timesyncd bluetooth.service cups.socket cups.path cups.service fstrim.timer"
USER_UNITS="qs-lock.service quickshell.service awww.service hypridle.service hyprpolkitagent.service"

# Dalla radice del repo, qualunque sia la cartella di partenza
cd "$(dirname "$0")"

step() {
  printf '\n── %s ──\n' "$1"
}

die() {
  echo "install.sh: $1" >&2
  exit 1
}

# Stesso filtro del README: via commenti, spazi e righe vuote
names() {
  sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' "$1"
}

[ "$(id -u)" -ne 0 ] || die "lancialo come utente normale, non con sudo"
# Stow collega nella cartella superiore: il repo deve stare in ~/dotfiles
[ "$(pwd -P)" = "$(cd "$HOME/dotfiles" 2>/dev/null && pwd -P)" ] \
  || die "il repo deve stare in ~/dotfiles (README, sezione 2)"
# autologin.conf contiene il nome utente (README, sezione 10)
grep -q -- "--autologin $(id -un) " system/etc/systemd/system/getty@tty1.service.d/autologin.conf \
  || die "autologin.conf non nomina l'utente $(id -un): cambialo prima (README, sezione 10)"

sudo -v

step "multilib"
# Prima dei pacchetti: senza, steam e lib32-nvidia-utils fanno fallire tutta la transazione
if ! pacman-conf --repo-list | grep -qx multilib; then
  # Toglie il # dalla riga [multilib] e dalla riga Include che la segue
  sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
  pacman-conf --repo-list | grep -qx multilib || die "non riesco ad abilitare [multilib] in /etc/pacman.conf"
  echo "abilitato"
else
  echo "gia' abilitato"
fi

step "Pacchetti dei repo ufficiali"
# -Syu: database aggiornati (anche quello di multilib appena abilitato) e sistema allineato
names pkglist.txt | sudo pacman -Syu --needed -

step "yay"
if ! command -v yay >/dev/null; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  git clone https://aur.archlinux.org/yay.git "$tmp/yay"
  (cd "$tmp/yay" && makepkg -si)
else
  echo "gia' installato"
fi

step "Pacchetti AUR"
names pkglist-aur.txt | yay -S --needed -

step "Stow"
# Se ~/.config manca, Stow collegherebbe la cartella intera al primo pacchetto
mkdir -p "$HOME/.config"
# I file di /etc/skel bloccherebbero il pacchetto bash: messi da parte, non cancellati
for f in .bash_profile .bashrc; do
  if [ -f "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
    mv "$HOME/$f" "$HOME/$f.bak"
    echo "~/$f spostato in ~/$f.bak"
  fi
done
# Prima la prova: un conflitto annulla l'intero comando, meglio fermarsi con l'elenco
# shellcheck disable=SC2086 # un pacchetto per parola
if ! stow -n $STOW || ! stow -n --no-folding $STOW_NO_FOLDING; then
  die "conflitti con file gia' in ~: spostali da parte e rilancia (README, sezione 5, Conflitti)"
fi
# shellcheck disable=SC2086
stow -v $STOW
# shellcheck disable=SC2086
stow -v --no-folding $STOW_NO_FOLDING

step "File di sistema"
# Copiati e non collegati: un file letto da root non deve puntare nella home (README, sezione 6)
find system -type f | while read -r src; do
  dst="/${src#system/}"
  if cmp -s "$src" "$dst"; then
    echo "$dst invariato"
  else
    sudo install -Dm644 "$src" "$dst"
    echo "$dst copiato"
  fi
done
sudo systemctl daemon-reload

step "UKI"
# Niente logo Arch all'avvio; la UKI si rigenera anche per hooks.conf appena copiato
if [ -f /etc/mkinitcpio.d/linux.preset ]; then
  sudo sed -i 's|^default_options=.*|default_options=""|' /etc/mkinitcpio.d/linux.preset
fi
sudo mkinitcpio -P

step "Servizi di sistema"
# shellcheck disable=SC2086 # una unit per parola
sudo systemctl enable --now $SYSTEM_UNITS
# DNS dallo stub di systemd-resolved
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
if ! ls /etc/systemd/network/*.network >/dev/null 2>&1; then
  echo "attenzione: /etc/systemd/network/ non ha file .network, systemd-networkd non configura nessuna interfaccia" >&2
fi

step "Servizi utente"
systemctl --user daemon-reload
# Senza --now: partono con la sessione grafica (Requisite=graphical-session.target)
# shellcheck disable=SC2086
systemctl --user enable $USER_UNITS
# Il calendario solo se l'indirizzo iCal c'e' gia' (README, sezione 9)
if [ -f "$HOME/.local/share/vdirsyncer/google-ical-url" ]; then
  systemctl --user enable --now vdirsyncer.timer
fi
xdg-user-dirs-update

step "Fatto"
cat <<'EOF'
Riavvia con "systemctl reboot": il PC arriva da solo al lock.
Restano a mano (README, sezioni 8-9):
- sfondi in ~/Wallpapers, poi launcher (SUPER+Space) → Wallpaper
- calendario Google: indirizzo iCal e vdirsyncer
- chiave SSH in ~/.ssh e git remote set-url per fare push
- dischi in piu' in /etc/fstab
EOF
