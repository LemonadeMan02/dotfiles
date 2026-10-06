#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Autologin su tty1 (getty): avvia la sessione Hyprland gestita da uwsm.
# may-start verifica che sia un login su VT senza una sessione grafica gia' attiva:
# su altri TTY o via SSH resta una shell normale.
# exec: alla fine della sessione si torna al login, non a una shell aperta.
# stdout in /dev/null: i messaggi informativi di uwsm sporcherebbero l'avvio
# silenzioso; gli errori vanno su stderr e restano visibili.
if uwsm check may-start; then
    exec uwsm start hyprland.desktop >/dev/null
fi
