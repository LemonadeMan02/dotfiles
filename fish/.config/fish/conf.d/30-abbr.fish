# Abbreviazioni: si espandono alla pressione di spazio, cosi' vedi il comando reale
# Riferimento: `help abbr` — espansioni tra apici, altrimenti abbr legge `--x` come sue opzioni

if status is-interactive
    # ls moderno
    if command -q eza
        abbr -a ls 'eza --icons=auto --group-directories-first'
        abbr -a ll 'eza -l --icons=auto --group-directories-first --git'
        abbr -a la 'eza -la --icons=auto --group-directories-first --git'
        abbr -a lt 'eza --tree --level=2 --icons=auto'
    end

    # git
    abbr -a g git
    abbr -a gs 'git status -sb'
    abbr -a ga 'git add'
    abbr -a gc 'git commit'
    abbr -a gp 'git push'
    abbr -a gd 'git diff'
    abbr -a gl 'git log --oneline --graph --decorate -20'

    # pacman / sistema
    abbr -a pup 'sudo pacman -Syu'
    abbr -a pin 'sudo pacman -S'
    abbr -a prm 'sudo pacman -Rns'
    abbr -a pss 'pacman -Ss'
    abbr -a jf 'journalctl --user -f'

    # dotfiles
    abbr -a dot 'cd ~/dotfiles'
end
