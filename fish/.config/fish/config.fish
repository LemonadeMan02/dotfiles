# I file in conf.d/ vengono letti prima di questo, in ordine alfabetico
# Riferimento: `man fish-language` e https://fishshell.com/docs/current/

if status is-interactive
    # Niente messaggio di benvenuto
    set -g fish_greeting
end
