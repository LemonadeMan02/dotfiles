# Variabili d'ambiente: valgono anche per shell non interattive

# -g = solo sessione, niente scrittura in fish_variables; salta le dir inesistenti
fish_add_path -g ~/.local/bin

# bat usa i colori ANSI del terminale: segue kitty e quindi matugen
set -gx BAT_THEME ansi
