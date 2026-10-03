#!/bin/sh
# Copia il greeter in /etc/greetd: Stow lavora solo nella home, e questi file
# li legge l'utente greeter. Da rilanciare dopo ogni modifica sotto greeter/:
# il greeter la vede al prossimo login.
set -eu

# Senza sudo: @USER@ diventa chi lancia lo script, cioe' chi fa login
if [ "$(id -u)" -eq 0 ]; then
  echo "Lancialo senza sudo: lo chiede da solo" >&2
  exit 1
fi

# Dalla cartella greeter/, qualunque sia quella di partenza
cd "$(dirname "$0")"

# La config di default del pacchetto resta da parte, solo la prima volta
[ -e /etc/greetd/config.toml.default ] ||
  sudo cp /etc/greetd/config.toml /etc/greetd/config.toml.default

sed "s/@USER@/$(id -un)/" greetd/config.toml | sudo tee /etc/greetd/config.toml >/dev/null
sudo install -Dm644 greetd/hyprland.lua /etc/greetd/hyprland.lua
sudo rm -rf /etc/greetd/quickshell
sudo cp -r quickshell /etc/greetd/quickshell
# Leggibili dall'utente greeter qualunque sia l'umask
sudo chmod -R a+rX /etc/greetd

# Sfondo e colori della sessione: li scrive greeter-sync come te, li legge il greeter
sudo install -d -m 755 -o "$(id -un)" -g "$(id -gn)" /var/lib/greeter-theme
if [ -x "$HOME/.local/bin/greeter-sync" ]; then
  "$HOME/.local/bin/greeter-sync"
else
  echo "greeter-sync non trovato: stow -v --no-folding scripts systemd" >&2
fi

echo "Greeter installato in /etc/greetd"
