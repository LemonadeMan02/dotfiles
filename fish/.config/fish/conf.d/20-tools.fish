# Integrazioni dei tool: solo in sessione interattiva e solo se installati

if status is-interactive
    # Prompt (config in ~/.config/starship.toml)
    command -q starship; and starship init fish | source

    # `z <nome>` salta a directory recenti/frecenti
    command -q zoxide; and zoxide init fish | source

    # ctrl+r cronologia, ctrl+t file, alt+c cd
    command -q fzf; and fzf --fish | source
end
