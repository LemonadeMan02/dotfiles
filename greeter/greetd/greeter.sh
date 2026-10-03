#!/bin/sh
# Comando di greetd per il greeter, installato in /etc/greetd/greeter.sh.
# $1: l'utente da autenticare, lo scrive install.sh in config.toml

# Console del VT1 vuota e senza cursore: e' quella che resta a vista fra la chiusura
# del greeter e il primo fotogramma della sessione. Le scritte del boot spariscono
printf '\033[2J\033[H\033[?25l'

# GREETER_USER arriva a Quickshell attraverso Hyprland; systemd-cat manda l'output nel journal
exec systemd-cat -t greeter-hyprland env GREETER_USER="$1" Hyprland -c /etc/greetd/hyprland.lua
