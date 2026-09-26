#!/bin/sh
# Confronta pkglist.txt e pkglist-aur.txt con i pacchetti installati.
# Solo lettura: non installa e non rimuove niente.
# Uscita: 0 nessuna differenza, 1 almeno una differenza.
set -eu

# Sistema base: si installa con Arch, non sta nelle liste (README, sezione 1).
# Esclusi dalla sezione b); da aggiornare se cambi kernel o bootloader.
IGNORE="base efibootmgr grub intel-ucode linux linux-firmware mkinitcpio os-prober sof-firmware sudo zram-generator"

# Dalla radice del repo, qualunque sia la cartella di partenza
cd "$(dirname "$0")"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Stesso filtro del README: via commenti, spazi e righe vuote
names() {
  sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' "$1" | sort -u
}

names pkglist.txt > "$tmp/repo"
names pkglist-aur.txt > "$tmp/aur"
sort -u "$tmp/repo" "$tmp/aur" > "$tmp/lists"

found=0

# Titolo, poi il file o "nessuna differenza"
section() {
  printf '── %s ──\n' "$1"
  if [ -s "$2" ]; then
    cat "$2"
    found=1
  else
    echo "nessuna differenza"
  fi
  echo
}

# a) pacman -T esce con 127 se manca qualcosa: con set -e va catturato.
# Nomi come argomenti e non "-": da stdin pacman prova a riaprire il terminale.
rc=0
# shellcheck disable=SC2046 # un nome di pacchetto per parola, niente spazi
pacman -T $(cat "$tmp/lists") > "$tmp/missing" || rc=$?
[ "$rc" -eq 0 ] || [ "$rc" -eq 127 ] || exit "$rc"
section "In lista ma non installati" "$tmp/missing"

# b) Espliciti che nessuna delle due liste nomina, tolto il sistema base
pacman -Qqe | sort > "$tmp/explicit"
# shellcheck disable=SC2086 # IGNORE va diviso in parole
printf '%s\n' $IGNORE | sort -u > "$tmp/ignore"
sort -u "$tmp/lists" "$tmp/ignore" > "$tmp/known"
comm -23 "$tmp/explicit" "$tmp/known" > "$tmp/extra"
section "Installati espliciti ma assenti dalle liste" "$tmp/extra"

# c) AUR in pkglist.txt e repo ufficiali in pkglist-aur.txt
pacman -Qqm | sort > "$tmp/foreign"
pacman -Qqn | sort > "$tmp/native"
{
  comm -12 "$tmp/repo" "$tmp/foreign" | sed 's/$/  (in pkglist.txt, ma è AUR)/'
  comm -12 "$tmp/aur" "$tmp/native" | sed 's/$/  (in pkglist-aur.txt, ma è nei repo ufficiali)/'
} > "$tmp/wrong"
section "Nella lista sbagliata" "$tmp/wrong"

exit "$found"
